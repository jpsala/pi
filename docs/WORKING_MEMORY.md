# Working Memory

Estado vivo del workspace `pi`. Mantener corto.

Ultima actualizacion manual: 2026-07-09.

## Lectura Rapida

| Area | Estado | Abrir primero | Siguiente accion |
| --- | --- | --- | --- |
| Proyecto | pending | `docs/PROJECT.md` | Definir proposito real antes de crear producto/runtime/deploy. |
| Extensiones propias | active | `docs/topics/pi-extension-stack.md`, `pi-extensions/README.md` | Mantener source/scripts de `windows-input`, statusline y UX compacta. |
| Flow global Pi/AOS | external | `C:/dev/os/docs/topics/pi-extension-stack.md`, `C:/dev/os/docs/topics/agent-tool-routing.md` | No duplicar inventario ni routing aca; referenciar AOS upstream. |
| PI WEB/VPS | external | `C:/dev/infra/docs/runbooks/vps-operations.md` | Infra es fuente operativa; no tocar servicios/tunnels sin permiso. |
| Windows input | active | `docs/topics/windows-input-extension.md` | Instalar/restaurar con `scripts/install-windows-input.*`; verificar `/windows-input status`. |
| Statusline/UX | active | `docs/topics/pi-statusline-customization.md`, `pi-extensions/README.md` | Reaplicar scripts tras actualizar paquetes Pi y luego `/reload`. |

## Estado Actual

- `C:\dev\pi` es workspace de documentacion/codigo fuente para extensiones y configs Pi propias de JP.
- El inventario global de paquetes Pi y el flow de uso viven en `C:\dev\os`; este repo solo referencia esas fuentes para evitar drift.
- Extension global `windows-input.ts`: fuente en `pi-extensions/windows-input.ts`, instaladores en `scripts/install-windows-input.ps1` / `.sh`.
- Statusline compacta: snapshot `pi-extensions/pi-footer.json`, restauradores `scripts/apply-pi-statusline-customization.ps1` / `.sh`; `codex-usage` muestra `colchón:+/-N.Nd` (dias equivalentes de presupuesto normal vs plan) y se repara tras updates con esos scripts.
- UX compacta WebUI/tools: `pi-extensions/pi-tool-display.json`, `pi-extensions/pi-hide-messages.json`, restauradores `scripts/apply-pi-webui-ux.ps1` / `.sh`.
- Stack global Pi no se inventaria aca; `C:\dev\os` mantiene flow, routing, inventario y la regla `pi-dynamic-workflows` opt-in.

## Riesgos

- No inventar el proposito del workspace ni agregar runtime de producto.
- No guardar secretos, auth.json, tokens, mcp config sensible ni datos privados.
- No instalar/remover paquetes globales sin permiso explicito y backup de `settings.json`.
- No duplicar `windows-input.ts` en `.pi/extensions/` mientras exista globalmente.
- `windows-input.ts` usa internals de Pi; si rompe, desactivar con `/windows-input off` o mover la extension global.

## Proximo Paso Probable

Si JP pide actualizar/sincronizar Pi en otra PC: abrir `pi-extensions/README.md`, ejecutar primero status del script correspondiente, aplicar solo la pieza pedida, correr `/reload` y smoke-testear. Para decidir herramientas o paquetes, abrir `C:\dev\os`; para PI WEB/VPS, abrir `C:\dev\infra`.
