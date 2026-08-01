// @ts-nocheck -- portable source copy; Pi resolves its runtime types globally.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ATTENTION_EVENT = "wezterm-attention:mark";
const ASK_TOOLS = new Set(["ask_user", "ask_user_question"]);

/** Marks WezTerm tabs while an interactive question is waiting for JP. */
export default function weztermAttentionBridge(pi: ExtensionAPI): void {
  pi.on("tool_call", (event) => {
    if (ASK_TOOLS.has(event.toolName)) {
      pi.events.emit(ATTENTION_EVENT, {
        type: "notify",
        label: "Waiting for your answer",
      });
    }
  });

  pi.on("tool_result", (event) => {
    if (ASK_TOOLS.has(event.toolName)) {
      // The agent normally continues after the answer; return to working until
      // wezterm-attention receives agent_settled and publishes the final stop.
      pi.events.emit(ATTENTION_EVENT, { type: "thinking" });
    }
  });
}
