---
id: windows-input-extension
status: active
kind: how-to
triggers:
  - windows-input
  - seleccion pi
  - shift arrow
  - ctrl shift arrow
  - custom editor
  - extension input
primary_refs:
  - docs/topics/pi-agentic-os.md
  - C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
  - C:\Users\jpsal\AppData\Roaming\npm\node_modules\@earendil-works\pi-coding-agent\docs\extensions.md
---

# Windows Input Extension

## Estado

Extensión global instalada en:

```text
C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
```

Una sesión nueva de Pi la carga automáticamente desde la ubicación global. En sesiones ya abiertas, usar:

```text
/reload
```

## Qué hace

Reemplaza el editor principal del prompt de Pi con un `CustomEditor` que agrega semántica estilo Windows/VS Code:

- `Ctrl+A`: seleccionar todo.
- `Shift+Arrow`: extender selección.
- `Ctrl+Shift+Left/Right`: extender selección por palabra.
- `Shift+Home/End` y `Ctrl+Shift+Home/End`: seleccionar hasta límites de línea/documento.
- `Ctrl+C`: copiar selección; si no hay selección, delega comportamiento normal.
- `Ctrl+X`, `Backspace`, `Delete`, escritura y paste reemplazan selección.
- Status footer `win-input` cuando está activo.

## Comandos

```text
/windows-input status
/windows-input on
/windows-input off
/windows-input toggle
```

## Alcance

- Afecta el editor principal de prompts en modo TUI.
- No convierte automáticamente inputs auxiliares, dialogs, selectores, overlays ni selección por mouse.
- En Tabby requiere que Tabby no capture `Shift+Arrow` / `Ctrl+Shift+Arrow`; el workspace `C:\dev\tabby` ya documenta/libera esos hotkeys.

## Gotchas

- Usa internals JS del editor de Pi (`state`, métodos privados por duck typing). Si una actualización de Pi rompe selección/render, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`.
- No conviene copiar la misma extensión activa a `.pi/extensions/` mientras exista globalmente: Pi carga recursos globales y project-locales; comandos duplicados quedan sufijados (`/windows-input:1`) y puede haber dos wrappers del editor.
- Si se quiere versionar una copia fuente en este repo, guardarla fuera de `.pi/extensions/` o desactivar/remover la global antes de activar la project-local.

## Referencias Pi

- `docs/extensions.md`: ubicaciones global/project-local y `/reload`.
- `docs/tui.md`: APIs TUI y `CustomEditor`.
- `examples/extensions/modal-editor.ts`: ejemplo de editor custom.
