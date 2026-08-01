# Working Memory

Estado vivo del workspace `pi`. Mantener corto.

Ultima actualizacion manual: 2026-07-25.

## Lectura Rapida

| Area | Estado | Abrir primero | Siguiente accion |
| --- | --- | --- | --- |
| Proyecto | active | `docs/PROJECT.md` | Mantener sólo customizaciones Pi portables; no crear producto/runtime/deploy. |
| Extensiones propias | active | `docs/topics/pi-extension-stack.md`, `pi-extensions/README.md` | Mantener source/scripts de `windows-input`, statusline y UX compacta. |
| Flow global Pi/AOS | external | `C:/dev/os/docs/topics/pi-extension-stack.md`, `C:/dev/os/docs/topics/agent-tool-routing.md` | No duplicar inventario ni routing aca; referenciar AOS upstream. |
| PI WEB/VPS | external | `C:/dev/infra/docs/runbooks/vps-operations.md` | Infra es fuente operativa; no tocar servicios/tunnels sin permiso. |
| Notebook / sync | external | `C:/dev/infra/docs/runbooks/notebook-operations.md` | Usar el contrato canónico de Infra; no duplicar host, acceso, repos ni reglas de sync acá. |
| Windows input | active | `docs/topics/windows-input-extension.md` | Instalar/restaurar con `scripts/install-windows-input.*`; verificar `/windows-input status`. |
| Statusline/UX | active | `docs/topics/pi-statusline-customization.md`, `pi-extensions/README.md` | Reaplicar scripts tras actualizar paquetes Pi y luego `/reload`. |
| Tabs WezTerm/Pi | active | `docs/topics/wezterm-attention.md`, `C:/dev/wezterm/docs/topics/wezterm-config.md` | Abrir handoffs Pi en un tab nombrado de la ventana WezTerm actual; mantener attention sincronizado. |

## Estado Actual

- `C:\dev\pi` es el laboratorio durable y reversible de personalizacion Pi de JP: registra extensiones probadas, fuentes/patches/configs saneadas, scripts/toggles, comportamiento de APIs, backups, smokes y rollback para poder retomar, cambiar o volver atras.
- El inventario global de paquetes Pi y el flow de uso viven en `C:\dev\os`; este repo solo referencia esas fuentes para evitar drift.
- Extensiones propias portables: `windows-input.ts` y `codex-quota.ts` viven en `pi-extensions/`; keybindings, theme y config de `pi-sticky-input` tienen snapshots saneados en la misma carpeta. Los instaladores existentes de Windows Input siguen en `scripts/install-windows-input.ps1` / `.sh`. En Windows, `windows-input` normaliza paths de drive (`C:\x` → `C:/x`) solo en `!`/`!!` antes de delegar a Git Bash; backup global `windows-input-paths-20260731-123316`.
- Statusline: `pi-footer@0.5.0` quedó filtrado (`extensions: []`) por agregar ~3 s al arranque; se usa el footer nativo de Pi. `pi-openai-usage@0.1.3` sigue activo con polling de 10 min y patch `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch`; debe publicar `7d: NN% · ↺ NdNh · margen ±Nh` en los statuses nativos. Backup del recorte: `~/.pi/agent/backups/pi-startup-trim-20260731-155743/`. Investigación y smoke pendiente: `docs/tracks/pi-startup-alternatives.md`. Los restauradores históricos de statusline todavía pueden reactivar/reparar `pi-footer`, por lo que no deben ejecutarse salvo rollback deliberado.
- Modo ultra compacto global: `pi-compact-transcript@0.6.2` colapsa todas las tools built-in/custom a una línea y conserva el renderer original con `Ctrl+O`; `pi-code-previews@0.1.36` queda para detalle built-in, con `hideThinkingBlock: true` y `outputPad: 0`. `pi-tool-display@0.5.0` está instalado pero inactivo por la limitación cross-extension de Pi `0.82.1`. Backup: `pi-compact-transcript-20260725-202053`; estado y rollback: `docs/topics/pi-tool-renderer.md`. El VPS conserva el stack anterior y requiere sync autorizado.
- `pi-sticky-input` mantiene `mouseScroll: false`; la rueda de Windows Terminal se traduce a `Ctrl+PageUp/PageDown` desde `C:/dev/main` commit `b916350`, preservando seleccion nativa.
- WezTerm Attention activo: writer global `pro-vi/wezterm-attention`, bridge portable `pi-extensions/wezterm-attention-bridge.ts` para `ask_user`/`ask_user_question`, y renderer local en `C:/dev/wizterm/config/plugins.lua`. `/reload` recarga Pi; la parte visual requiere recargar la configuración de WezTerm o reiniciarlo. Backup global `wezterm-attention-20260731-183913`; guía y rollback en `docs/topics/wezterm-attention.md`.
- UX compacta WebUI histórica: `pi-extensions/pi-tool-display.json` queda como snapshot inactivo en PC y aún aplica al stack anterior del VPS; `pi-extensions/pi-hide-messages.json` y restauradores `scripts/apply-pi-webui-ux.ps1` / `.sh` siguen vigentes.
- Stack global Pi no se inventaría acá; `C:\dev\os` mantiene `/flow`, routing e inventario. Este repo sólo declara `aos.requirements.json`. `pi-subagents-lite@1.6.0` quedó filtrado por costo de arranque y fue reemplazado por `pi-sub-agent@0.1.5`, medido en ~0,07 s sobre baseline; RPC confirmó `/sub-agent-settings`.
- AOS 1.1 alineado: Hacer abre una sesión enlazada con handoff documental y ejecuta allí sin Agent ni auto-send; Windows Input, footer/statusline, UX y experimentos aislados quedaron preservados. Backup: `~/.pi/agent/backups/aos-align-pi-1.1-20260722-093728/`.
- Plannotator fue retirado del runtime global Pi el 2026-07-14; este repo no conserva fuente ni configuracion local para restaurarlo.

## Riesgos

- No inventar el proposito del workspace ni agregar runtime de producto.
- No guardar secretos, auth.json, tokens, mcp config sensible ni datos privados.
- No instalar/remover paquetes globales sin permiso explicito y backup de `settings.json`.
- No duplicar `windows-input.ts` en `.pi/extensions/` mientras exista globalmente.
- `windows-input.ts` usa internals de Pi; si rompe, desactivar con `/windows-input off` o mover la extension global.

## Foco Único De Ejecución

- **Estado:** `waiting_gate`.
- **Referencia:** `docs/tracks/pi-ui-usage-evaluation.md`.
- **Gate:** Ejecutar `/reload` en las sesiones abiertas y confirmar en Copicu/Constelaciones que FFF, CodeMapper, Pi Lens y built-ins quedan en una línea, `Ctrl+O` revela el detalle y el margen semanal sigue visible.
- **Siguiente acción:** Cerrar el track si el smoke humano pasa; si falla, alternar `/compact-transcript status|on` y registrar la tool puntual sin tocar producto.
