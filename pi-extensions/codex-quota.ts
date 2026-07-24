// @ts-nocheck
import { readFile } from "node:fs/promises";
import { extname, resolve } from "node:path";
import { Type, type ImageContent, type TextContent } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MILLISECONDS_PER_HOUR = 60 * 60 * 1000;
const HOURS_PER_CALENDAR_WEEK = 7 * 24;
const MAX_IMAGE_BYTES = 10 * 1024 * 1024;
const IMAGE_TYPES: Record<string, { mediaType: string }> = {
  ".gif": { mediaType: "image/gif" },
  ".jpeg": { mediaType: "image/jpeg" },
  ".jpg": { mediaType: "image/jpeg" },
  ".png": { mediaType: "image/png" },
  ".webp": { mediaType: "image/webp" },
};

export interface CodexQuotaInput {
  remainingPercent: number;
  resetAt: string | Date;
  now?: string | Date;
  hoursPerDay?: number;
  daysPerWeek?: number;
}

export interface CodexQuotaEstimate {
  nowIso: string;
  resetAtIso: string;
  cycleStartIso: string;
  timezoneAssumed: boolean;
  remainingPercent: number;
  consumedPercent: number;
  hoursPerDay: number;
  daysPerWeek: number;
  weeklyHours: number;
  calendarHoursElapsed: number;
  calendarHoursRemaining: number;
  elapsedScheduledHours: number;
  plannedRemainingHours: number;
  observedBurnPercentPerActiveHour: number | null;
  observedDailyBurnPercent: number | null;
  requiredPercentPerActiveHour: number;
  requiredDailyBudgetPercent: number;
  supportedRemainingHours: number | null;
  marginHours: number | null;
}

function hasExplicitTimezone(value: string): boolean {
  return /(?:Z|[+-]\d{2}:?\d{2})$/iu.test(value.trim());
}

function parseDate(value: string | Date | undefined, field: string, fallback?: Date): { date: Date; timezoneAssumed: boolean } {
  if (value === undefined) {
    if (!fallback) throw new Error(`${field} es obligatorio.`);
    return { date: new Date(fallback.getTime()), timezoneAssumed: false };
  }

  const timezoneAssumed = typeof value === "string" && !hasExplicitTimezone(value);
  const date = value instanceof Date ? new Date(value.getTime()) : new Date(value);
  if (Number.isNaN(date.getTime())) throw new Error(`${field} no es una fecha válida.`);
  return { date, timezoneAssumed };
}

function assertFiniteInRange(value: number, field: string, minimum: number, maximum: number): void {
  if (!Number.isFinite(value) || value < minimum || value > maximum) {
    throw new Error(`${field} debe estar entre ${minimum} y ${maximum}.`);
  }
}

export function calculateCodexQuota(input: CodexQuotaInput): CodexQuotaEstimate {
  assertFiniteInRange(input.remainingPercent, "remainingPercent", 0, 100);
  const hoursPerDay = input.hoursPerDay ?? 12;
  const daysPerWeek = input.daysPerWeek ?? 6.5;
  assertFiniteInRange(hoursPerDay, "hoursPerDay", 0.01, 24);
  assertFiniteInRange(daysPerWeek, "daysPerWeek", 0.01, 7);

  const reset = parseDate(input.resetAt, "resetAt");
  const now = parseDate(input.now, "now", new Date());
  const resetAt = reset.date;
  const current = now.date;
  const cycleStart = new Date(resetAt.getTime() - HOURS_PER_CALENDAR_WEEK * MILLISECONDS_PER_HOUR);
  const elapsedMilliseconds = current.getTime() - cycleStart.getTime();
  const remainingMilliseconds = resetAt.getTime() - current.getTime();

  if (remainingMilliseconds <= 0) throw new Error("El reset ya ocurrió; no se puede estimar esta semana.");
  if (elapsedMilliseconds < 0) throw new Error("now está antes del inicio del ciclo de cuota.");

  const calendarHoursElapsed = elapsedMilliseconds / MILLISECONDS_PER_HOUR;
  const calendarHoursRemaining = remainingMilliseconds / MILLISECONDS_PER_HOUR;
  const weeklyHours = hoursPerDay * daysPerWeek;
  const elapsedScheduledHours = weeklyHours * calendarHoursElapsed / HOURS_PER_CALENDAR_WEEK;
  const plannedRemainingHours = weeklyHours - elapsedScheduledHours;
  const consumedPercent = 100 - input.remainingPercent;
  if (elapsedScheduledHours === 0 && consumedPercent > 0) {
    throw new Error("No se puede inferir un ritmo desde el inicio exacto del ciclo con cuota consumida.");
  }

  const observedBurnPercentPerActiveHour = elapsedScheduledHours > 0 && consumedPercent > 0
    ? consumedPercent / elapsedScheduledHours
    : null;
  const observedDailyBurnPercent = observedBurnPercentPerActiveHour === null
    ? null
    : observedBurnPercentPerActiveHour * hoursPerDay;
  const requiredPercentPerActiveHour = input.remainingPercent / plannedRemainingHours;
  const requiredDailyBudgetPercent = requiredPercentPerActiveHour * hoursPerDay;
  const supportedRemainingHours = observedBurnPercentPerActiveHour === null
    ? null
    : input.remainingPercent / observedBurnPercentPerActiveHour;
  const marginHours = supportedRemainingHours === null
    ? null
    : supportedRemainingHours - plannedRemainingHours;

  return {
    nowIso: current.toISOString(),
    resetAtIso: resetAt.toISOString(),
    cycleStartIso: cycleStart.toISOString(),
    timezoneAssumed: reset.timezoneAssumed || now.timezoneAssumed,
    remainingPercent: input.remainingPercent,
    consumedPercent,
    hoursPerDay,
    daysPerWeek,
    weeklyHours,
    calendarHoursElapsed,
    calendarHoursRemaining,
    elapsedScheduledHours,
    plannedRemainingHours,
    observedBurnPercentPerActiveHour,
    observedDailyBurnPercent,
    requiredPercentPerActiveHour,
    requiredDailyBudgetPercent,
    supportedRemainingHours,
    marginHours,
  };
}

function formatDate(iso: string): string {
  return new Intl.DateTimeFormat("es-AR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZoneName: "short",
  }).format(new Date(iso));
}

function formatDuration(hours: number): string {
  const totalMinutes = Math.max(0, Math.round(hours * 60));
  const days = Math.floor(totalMinutes / (24 * 60));
  const remainingMinutes = totalMinutes % (24 * 60);
  const wholeHours = Math.floor(remainingMinutes / 60);
  const minutes = remainingMinutes % 60;
  return `${days}d ${wholeHours}h ${minutes}m`;
}

function formatNumber(value: number): string {
  return value.toFixed(1).replace(".", ",");
}

export function formatCodexQuotaEstimate(estimate: CodexQuotaEstimate): string {
  const margin = estimate.marginHours === null
    ? "indeterminado (todavía no hay ritmo observado)"
    : `${estimate.marginHours >= 0 ? "+" : ""}${formatNumber(estimate.marginHours)} h`;
  const supported = estimate.supportedRemainingHours === null
    ? "indeterminadas"
    : `${formatNumber(estimate.supportedRemainingHours)} h activas`;
  const observedRate = estimate.observedBurnPercentPerActiveHour === null
    ? "sin ritmo observado"
    : `${formatNumber(estimate.observedBurnPercentPerActiveHour)}%/h activa (${formatNumber(estimate.observedDailyBurnPercent ?? 0)}% por día)`;

  return [
    "Estimación de cuota Codex",
    `- Ahora: ${formatDate(estimate.nowIso)}`,
    `- Reset: ${formatDate(estimate.resetAtIso)} (${formatDuration(estimate.calendarHoursRemaining)} calendario)`,
    `- Saldo: ${formatNumber(estimate.remainingPercent)}% restante; ${formatNumber(estimate.consumedPercent)}% consumido`,
    `- Actividad asumida: ${formatNumber(estimate.hoursPerDay)} h/día × ${formatNumber(estimate.daysPerWeek)} días/semana = ${formatNumber(estimate.weeklyHours)} h/semana`,
    `- Ritmo observado: ${observedRate}`,
    `- Presupuesto para gastar el saldo justo: ${formatNumber(estimate.requiredDailyBudgetPercent)}% por día`,
    `- Capacidad al ritmo observado: ${supported}`,
    `- Horas activas planificadas hasta el reset: ${formatNumber(estimate.plannedRemainingHours)} h`,
    `- Margen estimado: ${margin}`,
    estimate.timezoneAssumed ? "- Nota: alguna fecha no tenía zona horaria explícita; se usó la zona local." : "",
    "- Es una estimación: supone que el ritmo de consumo y las horas activas se mantienen uniformes durante la semana calendario.",
  ].filter(Boolean).join("\n");
}

function tokenizeArgs(args: string): string[] {
  const tokens: string[] = [];
  const pattern = /"([^"\\]*(?:\\.[^"\\]*)*)"|'([^']*)'|(\S+)/g;
  for (const match of args.matchAll(pattern)) tokens.push(match[1] ?? match[2] ?? match[3]);
  return tokens;
}

function normalizeImagePath(input: string, cwd: string): string {
  const path = input.startsWith("@") ? input.slice(1) : input;
  return resolve(cwd, path);
}

async function sendImageToVisionModel(
  pi: ExtensionAPI,
  imagePath: string,
  cwd: string,
  hoursPerDay = 12,
  daysPerWeek = 6.5,
  busy = false,
): Promise<void> {
  const absolutePath = normalizeImagePath(imagePath, cwd);
  const imageType = IMAGE_TYPES[extname(absolutePath).toLowerCase()];
  if (!imageType) throw new Error("La imagen debe ser PNG, JPEG, GIF o WebP.");

  const image = await readFile(absolutePath);
  if (image.byteLength === 0) throw new Error("La imagen está vacía.");
  if (image.byteLength > MAX_IMAGE_BYTES) throw new Error("La imagen supera el límite local de 10 MB.");

  const prompt = [
    "Analizá la imagen adjunta como captura de uso de Codex.",
    "Extraé el porcentaje restante y la fecha/hora exacta de reset.",
    `Usá hoursPerDay=${hoursPerDay} y daysPerWeek=${daysPerWeek}.`,
    "Después llamá la herramienta codex_quota con esos datos y explicá el margen estimado.",
    "No conviertas porcentaje a horas sin usar el ritmo de consumo observado; declará cualquier zona horaria inferida.",
  ].join(" ");
  const content: (TextContent | ImageContent)[] = [
    { type: "text", text: prompt },
    { type: "image", mimeType: imageType.mediaType, data: image.toString("base64") },
  ];
  if (busy) {
    pi.sendUserMessage(content, { deliverAs: "followUp" });
  } else {
    pi.sendUserMessage(content);
  }
}

const codexQuotaTool = defineTool({
  name: "codex_quota",
  label: "Codex Quota",
  description: "Calcula una estimación de cuota Codex a partir del porcentaje restante y la fecha/hora de reset extraídos de una captura.",
  promptSnippet: "Calcular cuota Codex desde una captura de uso",
  promptGuidelines: [
    "Usá codex_quota cuando el usuario adjunte una captura de cuota Codex o pida estimar horas restantes.",
    "Extraé remainingPercent y resetAt de la imagen antes de llamar codex_quota; incluí la zona horaria si está disponible.",
    "codex_quota estima horas usando el ritmo de consumo observado; no conviertas porcentaje restante a horas sin ese ritmo.",
  ],
  parameters: Type.Object({
    remainingPercent: Type.Number({ description: "Porcentaje de cuota restante (0 a 100).", minimum: 0, maximum: 100 }),
    resetAt: Type.String({ description: "Fecha/hora del reset, idealmente ISO 8601 con zona horaria." }),
    now: Type.Optional(Type.String({ description: "Fecha/hora actual ISO 8601; omitíla para usar la hora local del proceso." })),
    hoursPerDay: Type.Optional(Type.Number({ description: "Horas activas por día. Por defecto: 12.", minimum: 0.01, maximum: 24 })),
    daysPerWeek: Type.Optional(Type.Number({ description: "Días activos por semana. Por defecto: 6.5.", minimum: 0.01, maximum: 7 })),
  }),
  async execute(_toolCallId, params) {
    const estimate = calculateCodexQuota(params);
    return {
      content: [{ type: "text", text: formatCodexQuotaEstimate(estimate) }],
      details: estimate,
    };
  },
});

export default function codexQuota(pi: ExtensionAPI) {
  pi.registerTool(codexQuotaTool);

  pi.registerCommand("codex-quota", {
    description: "Analiza una captura de cuota Codex o calcula con datos manuales.",
    handler: async (args, ctx) => {
      const fields = tokenizeArgs(args.trim());
      if (fields.length === 0) {
        ctx.ui.notify("Uso: /codex-quota <imagen> [horas/día] [días/semana] o /codex-quota <porcentaje> <reset ISO> [ahora ISO] [horas/día] [días/semana]", "info");
        return;
      }

      if (!Number.isNaN(Number(fields[0]))) {
        if (fields.length < 2) {
          ctx.ui.notify("Faltan datos. Ejemplo: /codex-quota 76 2026-07-25T00:49:00-03:00", "warning");
          return;
        }
        try {
          const estimate = calculateCodexQuota({
            remainingPercent: Number(fields[0]),
            resetAt: fields[1],
            now: fields[2],
            hoursPerDay: fields[3] === undefined ? undefined : Number(fields[3]),
            daysPerWeek: fields[4] === undefined ? undefined : Number(fields[4]),
          });
          ctx.ui.notify(formatCodexQuotaEstimate(estimate), "info");
        } catch (error) {
          ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
        }
        return;
      }

      try {
        const hoursPerDay = fields[1] === undefined ? 12 : Number(fields[1]);
        const daysPerWeek = fields[2] === undefined ? 6.5 : Number(fields[2]);
        assertFiniteInRange(hoursPerDay, "hoursPerDay", 0.01, 24);
        assertFiniteInRange(daysPerWeek, "daysPerWeek", 0.01, 7);
        await sendImageToVisionModel(pi, fields[0], ctx.cwd, hoursPerDay, daysPerWeek, !ctx.isIdle());
        ctx.ui.notify("Captura enviada al modelo de visión para calcular la cuota.", "info");
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });

  pi.on("before_agent_start", (event) => {
    if (!event.images?.length || !/codex|quota|cuota|consumo|límite|limite|reset/iu.test(event.prompt)) return;
    return {
      systemPrompt: `${event.systemPrompt}\n\nLa solicitud incluye una imagen de uso de Codex. Leé de ella el porcentaje restante y la fecha/hora de reset, luego llamá la herramienta codex_quota con esos datos. Si falta la zona horaria, declaralo como supuesto. No trates el porcentaje como horas sin calcular primero el ritmo de consumo observado.`,
    };
  });
}
