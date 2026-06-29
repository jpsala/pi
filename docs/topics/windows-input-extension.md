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
  - pi-extensions/README.md
  - pi-extensions/windows-input.ts
  - scripts/install-windows-input.sh
  - scripts/install-windows-input.ps1
  - C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
  - C:\Users\jpsal\AppData\Roaming\npm\node_modules\@earendil-works\pi-coding-agent\docs\extensions.md
---

# Windows Input Extension

## Estado

Extensión global instalada en esta PC en:

```text
C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
```

Copia fuente versionable e instaladores en el proyecto:

```text
pi-extensions/windows-input.ts
pi-extensions/README.md
scripts/install-windows-input.sh
scripts/install-windows-input.ps1
```

Una sesión nueva de Pi carga automáticamente la ubicación global. En sesiones ya abiertas, usar:

```text
/reload
```

## Qué hace

No es específica de Windows como sistema operativo: el nombre describe la semántica de edición tipo Windows/VS Code. La extensión debería funcionar también en Linux/macOS si el terminal entrega las combinaciones de teclas a Pi.

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
- En Linux, `Ctrl+C` / `Ctrl+X` intentan copiar con `wl-copy` en Wayland o `xclip` en X11; sin esas utilidades, la selección funciona pero el clipboard puede no integrarse.

## Instalar en otra PC

Cuando JP pida instalar esta extensión en otra PC, el agente debe abrir este topic y `pi-extensions/README.md`, verificar estado, instalar una sola copia y recordar ejecutar `/reload` en Pi si la sesión estaba abierta.

Instalación global recomendada desde la raíz del repo:

```powershell
# Windows PowerShell
./scripts/install-windows-input.ps1 -Status
./scripts/install-windows-input.ps1 -Scope Global
```

```bash
# Linux/macOS/Git Bash
scripts/install-windows-input.sh --status
scripts/install-windows-input.sh --global
```

Luego abrir Pi o ejecutar `/reload`.

Instalación manual equivalente:

```powershell
# Windows PowerShell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.pi\agent\extensions" | Out-Null
Copy-Item .\pi-extensions\windows-input.ts "$env:USERPROFILE\.pi\agent\extensions\windows-input.ts" -Force
```

```bash
# Linux/macOS
mkdir -p ~/.pi/agent/extensions
cp pi-extensions/windows-input.ts ~/.pi/agent/extensions/windows-input.ts
```

Para activarla solo en este repo, usar `scripts/install-windows-input.sh --project --remove-global` o `./scripts/install-windows-input.ps1 -Scope Project -RemoveGlobal`. Hacerlo únicamente si no se quiere una copia global activa, para evitar doble carga.

## Gotchas

- Usa internals JS del editor de Pi (`state`, métodos privados por duck typing). Si una actualización de Pi rompe selección/render, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`.
- No conviene copiar la misma extensión activa a `.pi/extensions/` mientras exista globalmente: Pi carga recursos globales y project-locales; comandos duplicados quedan sufijados (`/windows-input:1`) y puede haber dos wrappers del editor.
- Si se quiere versionar una copia fuente en este repo, guardarla fuera de `.pi/extensions/` o desactivar/remover la global antes de activar la project-local.

## Referencias Pi

- `docs/extensions.md`: ubicaciones global/project-local y `/reload`.
- `docs/tui.md`: APIs TUI y `CustomEditor`.
- `examples/extensions/modal-editor.ts`: ejemplo de editor custom.
