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

## Estado Actual

- `C:\dev\pi` es el laboratorio durable y reversible de personalizacion Pi de JP: registra extensiones probadas, fuentes/patches/configs saneadas, scripts/toggles, comportamiento de APIs, backups, smokes y rollback para poder retomar, cambiar o volver atras.
- El inventario global de paquetes Pi y el flow de uso viven en `C:\dev\os`; este repo solo referencia esas fuentes para evitar drift.
- Extensiones propias portables: `windows-input.ts` y `codex-quota.ts` viven en `pi-extensions/`; keybindings, theme y config de `pi-sticky-input` tienen snapshots saneados en la misma carpeta. Los instaladores existentes de Windows Input siguen en `scripts/install-windows-input.ps1` / `.sh`.
- Statusline compacta: `pi-openai-usage@0.1.3` con polling de 10 min y patch `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch`; salida RPC `7d: NN% · ↺ NdNh · margen ±Nh`. El margen reutiliza el cache y los defaults de `/codex-quota` (12 h/dia × 6,5 dias/semana); el comando conserva el detalle manual. Restauradores Windows/POSIX validan version y patch. Backups: adopcion `~/.pi/agent/backups/openai-usage-adoption-20260722-104538/`, margen `~/.pi/agent/backups/openai-usage-margin-20260722-112058/`.
- Modo ultra compacto sin patch local activo: `hideThinkingBlock: true`; `pi-code-previews@0.1.36` upstream limpio posee built-ins sin previews, y `pi-tool-display@0.5.0` precede a `pi-fff` para resumir `ffgrep`/`fffind`. PC y VPS quedaron alineados en Pi `0.82.1`; backup remoto `pi-ultra-compact-parity-20260725-145903`. Snapshots y rollback: `docs/topics/pi-tool-renderer.md`.
- `pi-sticky-input` mantiene `mouseScroll: false`; la rueda de Windows Terminal se traduce a `Ctrl+PageUp/PageDown` desde `C:/dev/main` commit `b916350`, preservando seleccion nativa.
- UX compacta WebUI/tools: `pi-extensions/pi-tool-display.json`, `pi-extensions/pi-hide-messages.json`, restauradores `scripts/apply-pi-webui-ux.ps1` / `.sh`.
- Stack global Pi no se inventaría acá; `C:\dev\os` mantiene `/flow`, routing e inventario. Este repo sólo declara `aos.requirements.json`.
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
- **Gate:** Confirmar visualmente el margen semanal despues de `/reload`.
- **Siguiente acción:** Cerrar el track tras el smoke visual o corregir el formato si falla.
