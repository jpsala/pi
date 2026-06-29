// @ts-nocheck
/**
 * Windows-like input editor for Pi.
 *
 * Project source copy for installing as a Pi extension on Windows or Linux.
 * Keep it outside `.pi/extensions/` by default to avoid double-loading when a
 * global copy is already installed.
 *
 * Prototype extension: replaces the main Pi prompt editor with a CustomEditor
 * that adds Windows/VS Code-ish selection semantics.
 *
 * Load/reload: run /reload in Pi after editing this file.
 * Toggle: /windows-input on|off|toggle|status
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	CURSOR_MARKER,
	decodeKittyPrintable,
	matchesKey,
	truncateToWidth,
	visibleWidth,
	type EditorTheme,
	type TUI,
} from "@earendil-works/pi-tui";
import { spawnSync } from "node:child_process";
import { platform } from "node:os";

type Pos = { line: number; col: number };
type Range = { start: Pos; end: Pos };

const graphemeSegmenter = new Intl.Segmenter(undefined, { granularity: "grapheme" });

function clonePos(pos: Pos): Pos {
	return { line: pos.line, col: pos.col };
}

function comparePos(a: Pos, b: Pos): number {
	if (a.line !== b.line) return a.line - b.line;
	return a.col - b.col;
}

function normalizeText(text: string): string {
	return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n").replace(/\t/g, "    ");
}

function stripBracketedPaste(data: string): string | undefined {
	if (!data.includes("\x1b[200~")) return undefined;
	return data.replace(/^.*?\x1b\[200~/s, "").replace(/\x1b\[201~.*$/s, "");
}

function wrapLineWithPositions(line: string, contentWidth: number): Array<{ text: string; startIndex: number; endIndex: number }> {
	const width = Math.max(1, contentWidth);
	const segments = [...graphemeSegmenter.segment(line)] as Intl.SegmentData[];
	if (segments.length === 0) return [{ text: "", startIndex: 0, endIndex: 0 }];

	const chunks: Array<{ text: string; startIndex: number; endIndex: number }> = [];
	let text = "";
	let startIndex = segments[0]?.index ?? 0;
	let currentWidth = 0;

	for (const seg of segments) {
		const segmentWidth = visibleWidth(seg.segment);
		const endIndex = seg.index + seg.segment.length;
		if (text && currentWidth + segmentWidth > width) {
			chunks.push({ text, startIndex, endIndex: seg.index });
			text = seg.segment;
			startIndex = seg.index;
			currentWidth = segmentWidth;
			continue;
		}
		text += seg.segment;
		currentWidth += segmentWidth;
		if (currentWidth >= width) {
			chunks.push({ text, startIndex, endIndex });
			text = "";
			startIndex = endIndex;
			currentWidth = 0;
		}
	}

	if (text || chunks.length === 0) chunks.push({ text, startIndex, endIndex: line.length });
	return chunks;
}

function copyTextSync(text: string): void {
	const p = platform();
	try {
		if (p === "win32") {
			spawnSync("clip", { input: text, shell: true, stdio: ["pipe", "ignore", "ignore"] });
			return;
		}
		if (p === "darwin") {
			spawnSync("pbcopy", { input: text, stdio: ["pipe", "ignore", "ignore"] });
			return;
		}
		if (process.env.WAYLAND_DISPLAY) {
			const wl = spawnSync("wl-copy", { input: text, stdio: ["pipe", "ignore", "ignore"] });
			if (wl.status === 0) return;
		}
		spawnSync("xclip", ["-selection", "clipboard"], { input: text, stdio: ["pipe", "ignore", "ignore"] });
	} catch {
		// Keep editor behavior non-fatal if clipboard tooling is unavailable.
	}
}

class WindowsInputEditor extends CustomEditor {
	private selectionAnchor: Pos | null = null;

	private get stateAny(): any {
		return (this as any).state;
	}

	private get lines(): string[] {
		return this.stateAny.lines;
	}

	private get cursor(): Pos {
		return { line: this.stateAny.cursorLine, col: this.stateAny.cursorCol };
	}

	private setCursor(pos: Pos): void {
		const line = Math.max(0, Math.min(pos.line, this.lines.length - 1));
		const maxCol = this.lines[line]?.length ?? 0;
		this.stateAny.cursorLine = line;
		if (typeof (this as any).setCursorCol === "function") {
			(this as any).setCursorCol(Math.max(0, Math.min(pos.col, maxCol)));
		} else {
			this.stateAny.cursorCol = Math.max(0, Math.min(pos.col, maxCol));
		}
	}

	private docStart(): Pos {
		return { line: 0, col: 0 };
	}

	private docEnd(): Pos {
		const line = Math.max(0, this.lines.length - 1);
		return { line, col: this.lines[line]?.length ?? 0 };
	}

	private selectionRange(): Range | null {
		if (!this.selectionAnchor) return null;
		const focus = this.cursor;
		if (comparePos(this.selectionAnchor, focus) === 0) return null;
		return comparePos(this.selectionAnchor, focus) < 0
			? { start: clonePos(this.selectionAnchor), end: focus }
			: { start: focus, end: clonePos(this.selectionAnchor) };
	}

	private clearSelection(): void {
		this.selectionAnchor = null;
	}

	private beginOrKeepSelection(): void {
		if (!this.selectionAnchor) this.selectionAnchor = this.cursor;
	}

	private posToOffset(pos: Pos): number {
		let offset = 0;
		for (let i = 0; i < pos.line; i++) offset += (this.lines[i]?.length ?? 0) + 1;
		return offset + pos.col;
	}

	private offsetToPos(offset: number): Pos {
		let remaining = Math.max(0, offset);
		for (let line = 0; line < this.lines.length; line++) {
			const len = this.lines[line]?.length ?? 0;
			if (remaining <= len) return { line, col: remaining };
			remaining -= len + 1;
		}
		return this.docEnd();
	}

	private selectedText(): string {
		const range = this.selectionRange();
		if (!range) return "";
		// Use raw editor text because selection offsets are based on state.lines.
		// Expanded paste-marker text has different offsets and corrupts edits/copy ranges.
		const text = this.getText();
		return text.slice(this.posToOffset(range.start), this.posToOffset(range.end));
	}

	private replaceRange(range: Range, replacement: string): void {
		// Use raw editor text because range offsets are computed from state.lines.
		// getExpandedText() expands paste markers and can desynchronize offsets.
		const currentText = this.getText();
		const startOffset = this.posToOffset(range.start);
		const endOffset = this.posToOffset(range.end);
		const normalized = normalizeText(replacement);
		const nextText = currentText.slice(0, startOffset) + normalized + currentText.slice(endOffset);
		const cursor = this.offsetToPosInText(nextText, startOffset + normalized.length);

		this.cancelAutocompleteIfPossible();
		(this as any).pushUndoSnapshot?.();
		(this as any).lastAction = null;
		(this as any).exitHistoryBrowsing?.();
		this.stateAny.lines = nextText.split("\n");
		if (this.stateAny.lines.length === 0) this.stateAny.lines = [""];
		this.stateAny.cursorLine = cursor.line;
		this.stateAny.cursorCol = cursor.col;
		this.clearSelection();
		this.resetVerticalNavigationState();
		this.notifyChanged();
	}

	private offsetToPosInText(text: string, offset: number): Pos {
		const before = text.slice(0, Math.max(0, offset));
		const parts = before.split("\n");
		return { line: parts.length - 1, col: parts[parts.length - 1]?.length ?? 0 };
	}

	private deleteSelection(): boolean {
		const range = this.selectionRange();
		if (!range) return false;
		this.replaceRange(range, "");
		return true;
	}

	private replaceSelection(text: string): boolean {
		const range = this.selectionRange();
		if (!range) return false;
		this.replaceRange(range, text);
		return true;
	}

	private notifyChanged(): void {
		this.onChange?.(this.getText());
		this.tui.requestRender();
	}

	private resetVerticalNavigationState(): void {
		(this as any).preferredVisualCol = null;
		(this as any).snappedFromCursorCol = null;
	}

	private cancelAutocompleteIfPossible(): void {
		(this as any).cancelAutocomplete?.();
	}

	private collapseSelection(to: "start" | "end"): boolean {
		const range = this.selectionRange();
		if (!range) return false;
		this.setCursor(to === "start" ? range.start : range.end);
		this.clearSelection();
		this.tui.requestRender();
		return true;
	}

	private moveWithoutSelecting(data: string): void {
		super.handleInput(data);
		this.clearSelection();
	}

	private moveSelecting(fn: () => void): void {
		this.beginOrKeepSelection();
		fn();
		this.tui.requestRender();
	}

	private moveWordLeft(): void {
		(this as any).moveWordBackwards?.();
	}

	private moveWordRight(): void {
		(this as any).moveWordForwards?.();
	}

	private moveLineStart(): void {
		(this as any).moveToLineStart?.();
	}

	private moveLineEnd(): void {
		(this as any).moveToLineEnd?.();
	}

	private moveVisual(delta: -1 | 1): void {
		(this as any).moveCursor?.(delta, 0);
	}

	private selectAll(): void {
		this.selectionAnchor = this.docStart();
		this.setCursor(this.docEnd());
		this.tui.requestRender();
	}

	handleInput(data: string): void {
		const pasted = stripBracketedPaste(data);
		if (pasted !== undefined && this.selectionRange()) {
			this.replaceSelection(pasted);
			return;
		}

		if (matchesKey(data, "ctrl+z")) {
			this.clearSelection();
			(this as any).undo?.();
			this.tui.requestRender();
			return;
		}

		if (matchesKey(data, "ctrl+a")) {
			this.selectAll();
			return;
		}

		if (matchesKey(data, "ctrl+c")) {
			const selected = this.selectedText();
			if (selected) {
				copyTextSync(selected);
				return;
			}
			super.handleInput(data);
			return;
		}

		if (matchesKey(data, "ctrl+x")) {
			const selected = this.selectedText();
			if (selected) {
				copyTextSync(selected);
				this.deleteSelection();
				return;
			}
			super.handleInput(data);
			return;
		}

		if (matchesKey(data, "escape") && this.selectionRange()) {
			this.clearSelection();
			this.tui.requestRender();
			return;
		}

		if (matchesKey(data, "backspace") || matchesKey(data, "delete")) {
			if (this.deleteSelection()) return;
			super.handleInput(data);
			return;
		}

		if (matchesKey(data, "left")) {
			if (!this.collapseSelection("start")) this.moveWithoutSelecting(data);
			return;
		}
		if (matchesKey(data, "right")) {
			if (!this.collapseSelection("end")) this.moveWithoutSelecting(data);
			return;
		}
		if (matchesKey(data, "up") || matchesKey(data, "down") || matchesKey(data, "home") || matchesKey(data, "end") || matchesKey(data, "ctrl+left") || matchesKey(data, "ctrl+right")) {
			this.moveWithoutSelecting(data);
			return;
		}

		if (matchesKey(data, "shift+left")) {
			this.moveSelecting(() => super.handleInput("\x1b[D"));
			return;
		}
		if (matchesKey(data, "shift+right")) {
			this.moveSelecting(() => super.handleInput("\x1b[C"));
			return;
		}
		if (matchesKey(data, "shift+up")) {
			this.moveSelecting(() => this.moveVisual(-1));
			return;
		}
		if (matchesKey(data, "shift+down")) {
			this.moveSelecting(() => this.moveVisual(1));
			return;
		}
		if (matchesKey(data, "shift+home")) {
			this.moveSelecting(() => this.moveLineStart());
			return;
		}
		if (matchesKey(data, "shift+end")) {
			this.moveSelecting(() => this.moveLineEnd());
			return;
		}
		if (matchesKey(data, "ctrl+shift+left")) {
			this.moveSelecting(() => this.moveWordLeft());
			return;
		}
		if (matchesKey(data, "ctrl+shift+right")) {
			this.moveSelecting(() => this.moveWordRight());
			return;
		}
		if (matchesKey(data, "ctrl+shift+home")) {
			this.moveSelecting(() => this.setCursor(this.docStart()));
			return;
		}
		if (matchesKey(data, "ctrl+shift+end")) {
			this.moveSelecting(() => this.setCursor(this.docEnd()));
			return;
		}

		if (this.selectionRange() && this.isNewlineInsertion(data)) {
			this.replaceSelection("\n");
			return;
		}

		if (this.selectionRange() && this.isTextInsertion(data)) {
			this.replaceSelection(pasted ?? this.printableFromInput(data) ?? data);
			return;
		}

		super.handleInput(data);
		if (!this.isSelectionExtendingKey(data) && !this.isPureModifierOrRelease(data)) {
			// Normal editing/navigation clears the visual selection unless handled above.
			this.clearSelection();
		}
	}

	private isSelectionExtendingKey(data: string): boolean {
		return (
			matchesKey(data, "shift+left") ||
			matchesKey(data, "shift+right") ||
			matchesKey(data, "shift+up") ||
			matchesKey(data, "shift+down") ||
			matchesKey(data, "shift+home") ||
			matchesKey(data, "shift+end") ||
			matchesKey(data, "ctrl+shift+left") ||
			matchesKey(data, "ctrl+shift+right") ||
			matchesKey(data, "ctrl+shift+home") ||
			matchesKey(data, "ctrl+shift+end")
		);
	}

	private isPureModifierOrRelease(_data: string): boolean {
		return false;
	}

	private printableFromInput(data: string): string | undefined {
		// Plain printable chars arrive as single characters in most terminals.
		if (data.length === 1 && data.charCodeAt(0) >= 32) return data;
		// Kitty CSI-u printable chars can arrive as escape sequences; base Editor
		// handles them, so selection replacement must decode them too.
		const kittyPrintable = decodeKittyPrintable(data);
		if (kittyPrintable !== undefined) return kittyPrintable;
		if (matchesKey(data, "shift+space")) return " ";
		return undefined;
	}

	private isTextInsertion(data: string): boolean {
		return stripBracketedPaste(data) !== undefined || this.printableFromInput(data) !== undefined;
	}

	private isNewlineInsertion(data: string): boolean {
		return (
			matchesKey(data, "shift+enter") ||
			data === "\x1b\r" ||
			data === "\x1b[13;2~" ||
			data === "\x1b[13;2u" ||
			(data.length > 1 && data.includes("\x1b") && data.includes("\r")) ||
			(data === "\n" && data.length === 1)
		);
	}

	render(width: number): string[] {
		const anyThis = this as any;
		const paddingX = Math.min(Math.max(0, Math.floor(anyThis.paddingX ?? 0)), Math.max(0, Math.floor((width - 1) / 2)));
		const contentWidth = Math.max(1, width - paddingX * 2);
		const layoutWidth = Math.max(1, contentWidth - (paddingX ? 0 : 1));
		anyThis.lastWidth = layoutWidth;

		const layoutLines = this.layoutLinesWithPositions(layoutWidth);
		const terminalRows = this.tui.terminal.rows;
		const maxVisibleLines = Math.max(5, Math.floor(terminalRows * 0.3));
		let cursorLineIndex = layoutLines.findIndex((line) => line.hasCursor);
		if (cursorLineIndex === -1) cursorLineIndex = 0;

		let scrollOffset = anyThis.scrollOffset ?? 0;
		if (cursorLineIndex < scrollOffset) scrollOffset = cursorLineIndex;
		else if (cursorLineIndex >= scrollOffset + maxVisibleLines) scrollOffset = cursorLineIndex - maxVisibleLines + 1;
		const maxScrollOffset = Math.max(0, layoutLines.length - maxVisibleLines);
		scrollOffset = Math.max(0, Math.min(scrollOffset, maxScrollOffset));
		anyThis.scrollOffset = scrollOffset;

		const visibleLines = layoutLines.slice(scrollOffset, scrollOffset + maxVisibleLines);
		const result: string[] = [];
		const horizontal = this.borderColor("─");
		const leftPadding = " ".repeat(paddingX);
		const rightPadding = leftPadding;

		if (scrollOffset > 0) {
			const indicator = `─── ↑ ${scrollOffset} more `;
			const remaining = width - visibleWidth(indicator);
			result.push(this.borderColor(remaining >= 0 ? indicator + "─".repeat(remaining) : truncateToWidth(indicator, width)));
		} else {
			result.push(horizontal.repeat(width));
		}

		for (const layoutLine of visibleLines) {
			let displayText = this.renderTextLine(layoutLine);
			let lineVisibleWidth = visibleWidth(layoutLine.text);
			let cursorInPadding = false;
			if (layoutLine.hasCursor && layoutLine.cursorPos === layoutLine.text.length) {
				lineVisibleWidth += 1;
				if (lineVisibleWidth > contentWidth && paddingX > 0) cursorInPadding = true;
			}
			const padding = " ".repeat(Math.max(0, contentWidth - lineVisibleWidth));
			const lineRightPadding = cursorInPadding ? rightPadding.slice(1) : rightPadding;
			result.push(`${leftPadding}${displayText}${padding}${lineRightPadding}`);
		}

		const linesBelow = layoutLines.length - (scrollOffset + visibleLines.length);
		if (linesBelow > 0) {
			const indicator = `─── ↓ ${linesBelow} more `;
			const remaining = width - visibleWidth(indicator);
			result.push(this.borderColor(indicator + "─".repeat(Math.max(0, remaining))));
		} else {
			result.push(horizontal.repeat(width));
		}

		if (anyThis.autocompleteState && anyThis.autocompleteList) {
			const autocompleteResult = anyThis.autocompleteList.render(contentWidth);
			for (const line of autocompleteResult) {
				const lineWidth = visibleWidth(line);
				const linePadding = " ".repeat(Math.max(0, contentWidth - lineWidth));
				result.push(`${leftPadding}${line}${linePadding}${rightPadding}`);
			}
		}

		return result;
	}

	private layoutLinesWithPositions(contentWidth: number): Array<any> {
		const lines = this.lines;
		if (lines.length === 0 || (lines.length === 1 && lines[0] === "")) {
			return [{ text: "", logicalLine: 0, startCol: 0, endCol: 0, hasCursor: true, cursorPos: 0 }];
		}
		const out: Array<any> = [];
		const cursor = this.cursor;
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i] ?? "";
			const isCurrentLine = i === cursor.line;
			if (visibleWidth(line) <= contentWidth) {
				out.push({ text: line, logicalLine: i, startCol: 0, endCol: line.length, hasCursor: isCurrentLine, cursorPos: isCurrentLine ? cursor.col : undefined });
				continue;
			}
			const chunks = wrapLineWithPositions(line, contentWidth);
			for (let chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
				const chunk = chunks[chunkIndex];
				const isLastChunk = chunkIndex === chunks.length - 1;
				let hasCursor = false;
				let cursorPos = undefined;
				if (isCurrentLine) {
					if (isLastChunk) hasCursor = cursor.col >= chunk.startIndex;
					else hasCursor = cursor.col >= chunk.startIndex && cursor.col < chunk.endIndex;
					if (hasCursor) cursorPos = Math.min(cursor.col - chunk.startIndex, chunk.text.length);
				}
				out.push({ text: chunk.text, logicalLine: i, startCol: chunk.startIndex, endCol: chunk.endIndex, hasCursor, cursorPos });
			}
		}
		return out;
	}

	private renderTextLine(layoutLine: any): string {
		const range = this.selectionRange();
		const cursor = this.cursor;
		const emitCursorMarker = this.focused;
		let output = "";
		let emittedCursor = false;

		const segments = [...graphemeSegmenter.segment(layoutLine.text)] as Intl.SegmentData[];
		for (const seg of segments) {
			const rawStart = layoutLine.startCol + seg.index;
			const rawEnd = rawStart + seg.segment.length;
			const posStart = { line: layoutLine.logicalLine, col: rawStart };
			const selected = range && comparePos(posStart, range.start) >= 0 && comparePos(posStart, range.end) < 0;
			const isCursor = layoutLine.hasCursor && cursor.line === layoutLine.logicalLine && cursor.col >= rawStart && cursor.col < rawEnd;
			if (isCursor) {
				output += emitCursorMarker ? CURSOR_MARKER : "";
				emittedCursor = true;
			}
			output += selected || isCursor ? `\x1b[7m${seg.segment}\x1b[0m` : seg.segment;
		}

		if (layoutLine.hasCursor && layoutLine.cursorPos === layoutLine.text.length && !emittedCursor) {
			output += emitCursorMarker ? CURSOR_MARKER : "";
			output += "\x1b[7m \x1b[0m";
		}
		return output;
	}
}

export default function (pi: ExtensionAPI) {
	let enabled = true;

	const apply = (ctx: any) => {
		if (ctx.mode !== "tui") return;
		ctx.ui.setEditorComponent(
			enabled ? (tui: TUI, theme: EditorTheme, kb: any) => new WindowsInputEditor(tui, theme, kb) : undefined,
		);
		ctx.ui.setStatus("windows-input", enabled ? ctx.ui.theme.fg("accent", "win-input") : undefined);
	};

	pi.on("session_start", (_event, ctx) => {
		apply(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		ctx.ui.setStatus?.("windows-input", undefined);
	});

	pi.registerCommand("windows-input", {
		description: "Toggle Windows-like input editor prototype",
		handler: async (args, ctx) => {
			const action = String(args || "toggle").trim().toLowerCase();
			if (action === "on" || action === "enable") enabled = true;
			else if (action === "off" || action === "disable") enabled = false;
			else if (action === "toggle" || action === "") enabled = !enabled;
			else if (action !== "status") {
				ctx.ui.notify("Usage: /windows-input on|off|toggle|status", "warning");
				return;
			}
			apply(ctx);
			ctx.ui.notify(`Windows input prototype: ${enabled ? "on" : "off"}`, "info");
		},
	});
}
