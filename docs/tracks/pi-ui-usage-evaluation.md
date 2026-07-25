---
status: active
started: 2026-07-22
updated: 2026-07-25
priority: high
owner: JP
related:
  - docs/topics/pi-extension-stack.md
  - docs/topics/pi-tool-renderer.md
  - docs/topics/pi-statusline-customization.md
  - docs/topics/windows-input-extension.md
  - docs/WORKING_MEMORY.md
topic: docs/topics/pi-statusline-customization.md
source_refs:
  - pi-extensions/pi-footer.json
  - pi-extensions/pi-openai-usage.json
  - pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch
  - pi-extensions/windows-input.ts
  - scripts/apply-pi-statusline-customization.ps1
  - scripts/install-windows-input.ps1
---

# Pi UI And Usage Evaluation

## Objetivo

Dejar la TUI de Pi compacta y seleccionable, elegir un renderer granular de tools y restaurar un indicador configurable de cuota Codex sin sumar contexto ni actividad innecesaria.

## Estado Actual

### Seleccion y rueda del mouse

- La seleccion nativa de Windows Terminal fallaba porque `pi-sticky-input` tenia `mouseScroll: true` y activaba captura SGR del mouse; `windows-input.ts` no era la causa.
- Config persistente actual: `C:/Users/jpsal/.pi/agent/extensions/pi-sticky-input/config.json` con `mouseScroll: false`.
- Backup: `C:/Users/jpsal/.pi/agent/extensions/pi-sticky-input/config.json.bak-mouse-scroll-20260721-193252`.
- `C:/dev/main/hotkeys-global.ahk` traduce `WheelUp/WheelDown` a `Ctrl+PageUp/PageDown` solo en Windows Terminal, por lo que `pi-sticky-input` desplaza su historial sin capturar el mouse.
- Probe AHK y smoke fisico pasaron. Commit en `C:/dev/main`: `b916350` (`feat: scroll Windows Terminal history with mouse wheel`).

### Renderer de tools

- Modo ultra compacto: `hideThinkingBlock: true`; `pi-code-previews@0.1.36` upstream limpio posee built-ins sin fondo/previews y `pi-tool-display@0.5.0` sólo resume `ffgrep`/`fffind`.
- El patch local de code-previews quedó retirado; `pi-claude-code-ui@1.0.74` sigue desactivado y no hay ownership solapado.
- Backups: `pi-ultra-compact-20260725-111740` y `pi-code-previews-clean-restore-20260725-113303`; RPC aislado del renderer pasó.
- Pendiente sólo el smoke visual tras `/reload`: `ffgrep`, `fffind`, `read`, `edit` y expansión con `Ctrl+O`.
- VPS sincronizado el 2026-07-25: Pi `0.82.1`, stack común idéntico, snapshots con hashes iguales, RPC/PI WEB doctor verdes y backup `pi-ultra-compact-parity-20260725-145903`.
- Estado, fuentes, config y rollback canónicos: `docs/topics/pi-tool-renderer.md`.

### Cuota Codex

- `pi-openai-usage@0.1.3` esta instalada globalmente y publica `openai-usage`; `pi list` y el comando `/openai-usage-settings diagnostics` la confirmaron.
- Config global: `C:/Users/jpsal/.pi/agent/extensions/pi-openai-usage.json`; snapshot portable: `pi-extensions/pi-openai-usage.json`.
- Polling fijado en 10 minutos, sin label propio, color neutral y salida compacta con margen: `7d: 87% · ↺ 6d2h · margen -2h` en el smoke RPC mas reciente.
- El margen reutiliza el mismo fetch/cache y la formula de `codex-quota.ts`: 12 h/dia × 6,5 dias/semana, capacidad restante al ritmo observado menos horas activas planificadas.
- El footer instalado y `pi-extensions/pi-footer.json` consumen `openai-usage` mediante `jp-openai-usage`; ambos restauradores validan configs, version y parche.
- `/codex-quota` queda para el detalle manual de ritmo, capacidad y presupuesto diario.
- Backups: adopcion en `C:/Users/jpsal/.pi/agent/backups/openai-usage-adoption-20260722-104538/`; margen en `C:/Users/jpsal/.pi/agent/backups/openai-usage-margin-20260722-112058/`.

## Resultado De La Investigacion

### Adopcion: `pi-openai-usage@0.1.3`

Repositorio: `https://github.com/studioarray/pi-openai-usage`.

Motivos:

- Publica solo `ctx.ui.setStatus("openai-usage", ...)` y un comando de configuracion; no registra tools para el LLM y no agrega contexto.
- No declara dependencias runtime adicionales.
- Mantiene el snapshot en memoria y evita otra llamada mientras siga fresco, aunque reciba `turn_end`.
- Configura por UI o JSON: widgets 5h/7d, porcentaje/barra, resets, colores, etiquetas, separador y polling entre 15 segundos y 10 minutos.
- Usa el OAuth Codex ya resuelto por Pi y consulta `https://chatgpt.com/backend-api/wham/usage`.

Configuracion adoptada para esta PC:

- `refreshIntervalMs: 600000` (10 minutos; hasta 6 consultas/hora con Codex activo).
- Sin label general, sin barras, separador ` · ` y color neutral.
- El API observado devolvio una sola ventana primaria con `limit_window_seconds: 604800` y `secondary_window: null`.
- La version `0.1.3` nombra rigidamente la ventana primaria como 5h. Para no mostrar datos falsos, la config reutiliza ese slot con label `7d`, habilita su countdown y oculta los slots secundarios vacios.
- Parche local versionado identifica la ventana semanal por `limit_window_seconds: 604800`, no por el nombre rigido del slot.
- Salida validada por RPC: `7d: 87% · ↺ 6d2h · margen -2h`.
- El margen se actualiza con el cache existente; no agrega otro poller. Si todavia no hay ritmo observado muestra `margen --`; `/codex-quota` conserva el detalle bajo demanda.

Integracion aplicada:

1. Se reviso el tarball exacto `0.1.3` (`sha512-ubw9...XfIQ==`) y se creo backup antes de instalar.
2. Se instalo la version fijada y se creo la config global compacta con snapshot portable.
3. El footer migro de `codex-usage` a `openai-usage`, incluyendo `hiddenKeys`, `knownKeys` y `jp-openai-usage`.
4. `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch` agrega duracion de ventana y margen semanal con la misma formula/defaults de `/codex-quota`.
5. Los restauradores Windows y POSIX aplican idempotentemente el parche, exigen `0.1.3` y validan footer, config, version y marcadores; status y smokes sobre paquete limpio pasaron.

### Alternativas estudiadas

| Extension | Recursos / contexto | Configurabilidad | Decision |
| --- | --- | --- | --- |
| `pi-openai-usage` | Sin tools LLM; cache en memoria; polling hasta 10m | Muy alta | Recomendada. |
| `@narumitw/pi-usage` | Sin deps; cache 5m; auth runtime de Pi | Formato casi fijo; tambien OpenRouter | Robusta, pero no cumple el deseo de modificar el formato. |
| `pi-codex-status` | Inicio + headers oportunistas; cache en disco | Baja; CLI/comando potente | Muy eficiente, pero menos editable y registra `/status`. |
| `@calesennett/pi-codex-usage` | Codigo minimo, pero polling 1m y refresh tras cada turno | Solo `left/used`, principalmente 7d | Compatible con la key actual, pero demasiado limitada y potencialmente mas ruidosa en red. |
| `pi-quota-status` | Polling 1m, estado persistente con locks, reconciliacion CLI | Adapters y thresholds, poca libertad visual | Demasiada complejidad para solo Codex. |
| `@llblab/pi-codex-usage` | Polling 30s | Sin configuracion | Descartada. |
| `pi-codex-footer` / `@kmiyh/pi-codex-plan-limits` | Reemplazan footer; uno redibuja cada segundo | Footer propio | Descartadas por conflicto con `pi-footer`. |
| `pi-codexbar` | Requiere CLI externo, spawnea procesos y registra tool LLM | Amplia y multi-provider | Descartada por recursos/contexto/intrusion. |
| `@narumitw/pi-codex-usage` | Paquete anterior | — | Deprecada oficialmente; no instalar. |

## Evidencia / Source Refs

- `pi-openai-usage` configuracion: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/README.md#L55-L98>
- `pi-openai-usage` widgets: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/README.md#L109-L188>
- Cache que evita requests frescos: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/src/usage-refresh-coordinator.ts#L66-L94>
- Lifecycle y `openai-usage`: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/src/status-controller.ts#L90-L155>
- `@calesennett` polling/eventos: <https://github.com/calesennett/pi-codex-usage/blob/2cef805bc852b3f000763963a004521caa7f3e3f/extensions/codex-usage-status.ts#L22-L45>
- `pi-codex-status` headers: <https://github.com/lhl/pi-codex-status/blob/bc2643e01a13c8c7a849de5f6c572da4cfd2a5c9/src/extension.ts#L259-L273>
- `@narumitw/pi-usage`: <https://github.com/narumiruna/pi-extensions/blob/822ddf011ceeb6846f5da74d3bab6d4ee81e38f0/extensions/pi-usage/README.md#L5-L23>

## Proximo Smoke Y Mantenimiento

1. Ejecutar `/reload`; confirmar visualmente `ffgrep`/`fffind` compactos y `usage:7d: NN% · ↺ NdNh · margen ±Nh`.
2. En tools, probar además `read`, `edit` y `Ctrl+O`; en usage, RPC confirmó auth, fetch HTTP 200, status con margen y respuesta `success:true`. El cierre del probe RPC en Windows termina luego con un assertion libuv/código 127 separado del funcionamiento validado.
3. Si el API vuelve a publicar dos ventanas, el margen seguira buscando la ventana de 604800 segundos; revisar solo la presentacion 5h+7d.
4. Rollback del margen: restaurar `C:/Users/jpsal/.pi/agent/backups/openai-usage-margin-20260722-112058/` o revertir el patch sobre `pi-openai-usage@0.1.3`, luego `/reload`.
5. Rollback total: `pi remove npm:pi-openai-usage`, restaurar el backup de adopcion y ejecutar `/reload`.
6. No se hizo commit porque `C:/dev/pi` conserva cambios preexistentes ajenos.
