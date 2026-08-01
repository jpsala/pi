# Pi Extensions

Extensiones/configs fuente para instalar o restaurar Pi en otras maquinas.

> Importante: este repo guarda piezas propias de JP (`windows-input`, footer/statusline y UX compacta). El inventario global de paquetes y el flow de herramientas viven en `C:/dev/os/docs/topics/pi-extension-stack.md` y `C:/dev/os/docs/topics/agent-tool-routing.md`; no duplicarlos aca.
>
> Los archivos fuente no se colocan en `.pi/extensions/` por defecto porque esa carpeta se auto-carga cuando el proyecto esta confiado. Si tambien existe una copia global, Pi puede cargar dos wrappers y crear comandos sufijados.

## Para pedir instalacion en otra PC

Cuando estes en otra maquina con este repo disponible, podes pedirle al agente:

```text
Instala la extension windows-input de este repo para Pi. Usa pi-extensions/README.md y docs/topics/windows-input-extension.md. Prefiero instalacion global salvo que haya razon para project-local.
```

El agente debe:

1. Leer `docs/.generated/context-index.md`, `docs/WORKING_MEMORY.md`, `docs/TOPICS.md` y `docs/topics/windows-input-extension.md`.
2. Verificar estado con uno de estos comandos:
   - Linux/macOS/Git Bash: `scripts/install-windows-input.sh --status`
   - Windows PowerShell: `./scripts/install-windows-input.ps1 -Status`
3. Instalar globalmente, salvo pedido contrario:
   - Linux/macOS/Git Bash: `scripts/install-windows-input.sh --global`
   - Windows PowerShell: `./scripts/install-windows-input.ps1 -Scope Global`
4. Indicar que en Pi hay que ejecutar `/reload` si la sesion ya estaba abierta.
5. Verificar dentro de Pi con `/windows-input status`.

## Atención de tabs Pi en WezTerm

- Fuente portable del bridge: `pi-extensions/wezterm-attention-bridge.ts`.
- Writer global: `git:github.com/pro-vi/wezterm-attention`.
- Renderer visual local: `C:/dev/wizterm/config/plugins.lua`.
- Guía, smoke y rollback: `docs/topics/wezterm-attention.md`.

El bridge convierte `ask_user` y `ask_user_question` en `notify` para mostrar `!` rojo mientras esperan respuesta. `/reload` recarga esta extensión Pi; la parte visual necesita recargar la configuración de WezTerm o reiniciarlo.

## Statusline compacta de JP

Esta repo tambien guarda la configuracion compacta del footer/statusline de Pi:

- Snapshot footer: `pi-extensions/pi-footer.json`
- Snapshot usage: `pi-extensions/pi-openai-usage.json`
- Fuente `/codex-quota`: `pi-extensions/codex-quota.ts`
- Patch de margen semanal: `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch`
- Restaurador Windows: `scripts/apply-pi-statusline-customization.ps1`
- Restaurador Linux/macOS/VPS: `scripts/apply-pi-statusline-customization.sh`
- Guia: `docs/topics/pi-statusline-customization.md`

El restaurador copia las configs de `pi-footer` y `pi-openai-usage`, y reaplica parches locales en `pi-openai-usage`, `pi-footer` y `pi-chrome`. El patch de usage agrega `margen ±Nh` con la formula/defaults de `/codex-quota` sin duplicar polling. Requiere que `pi-openai-usage@0.1.3` ya este instalada; falla ante otra version y no instala paquetes.

Para restaurarla o igualarla en otra PC Windows:

```powershell
./scripts/apply-pi-statusline-customization.ps1 -Status
./scripts/apply-pi-statusline-customization.ps1
```

En Linux/macOS/VPS:

```bash
scripts/apply-pi-statusline-customization.sh --status
scripts/apply-pi-statusline-customization.sh
```

Luego ejecutar `/reload` dentro de Pi.

## Renderer de tools

- Transcript global: `pi-compact-transcript@0.6.2`; colapsa cualquier tool built-in/custom a una línea y devuelve el renderer original con `Ctrl+O`.
- Detalle built-in: `pi-code-previews@0.1.36`, sin fondo ni previews colapsadas; snapshot `pi-extensions/pi-code-previews.json`.
- `pi-tool-display@0.5.0` quedó instalado pero inactivo: Pi 0.82.1 no permite que una extensión decore públicamente renderers registrados por otra. Su snapshot se conserva como antecedente.
- `hideThinkingBlock: true` y `outputPad: 0` reducen el ruido restante; config viva en `~/.pi/agent/settings.json`.
- El patch `pi-code-previews-0.1.36-tools-authoritative.patch` queda sólo como antecedente; el paquete instalado es upstream limpio.
- Anterior: `pi-claude-code-ui@1.0.74`, instalada pero desactivada.
- Guía canónica de estado, fuentes, smokes y rollback: `docs/topics/pi-tool-renderer.md`.

No dar ownership de la misma tool a dos renderers. Backup del modo ultra compacto: `~/.pi/agent/backups/pi-ultra-compact-20260725-111740/`; el backup histórico de code-previews no debe restaurarse completo. Tras cambios, ejecutar `/reload`.

## UX compacta de tools y WebUI

Esta repo guarda tambien la configuracion de legibilidad para reducir ruido en Pi. Es configuracion local de JP, no dependencia AOS para repos destino:

- `pi-extensions/pi-code-previews.json`: detalle built-in sin fondo ni previews colapsadas.
- `pi-extensions/pi-tool-display.json`: snapshot histórico del renderer custom retirado; no representa un paquete activo.
- `pi-compact-transcript@0.6.2` no requiere config de archivo: se fija globalmente en `settings.json` y alterna por sesión con `/compact-transcript on|off`.
- `pi-extensions/pi-hide-messages.json`: mantiene visibles los ultimos 12 mensajes.
- `pi-extensions/pi-keybindings.json`: shortcuts globales compartidos.
- `pi-extensions/pi-sticky-input.json`: input/scroll compartido, con `mouseScroll: false`.
- `pi-extensions/jp-tokyo-night-user-focus.json`: theme global compartido.
- `scripts/apply-pi-webui-ux.ps1` / `.sh`: copia las configs de tool display/hide messages y parchea `@firstpick/pi-package-webui` cuando ese paquete existe.

Windows:

```powershell
./scripts/apply-pi-webui-ux.ps1
```

Linux/macOS/VPS:

```bash
scripts/apply-pi-webui-ux.sh
```

Luego reiniciar WebUI o hacer hard refresh del navegador, y ejecutar `/reload` dentro de Pi para las configs TUI.

Los otros snapshots portables se copian al perfil global respetando la plataforma:

```text
codex-quota.ts                     -> ~/.pi/agent/extensions/codex-quota.ts
pi-keybindings.json                -> ~/.pi/agent/keybindings.json
pi-sticky-input.json               -> ~/.pi/agent/extensions/pi-sticky-input/config.json
jp-tokyo-night-user-focus.json     -> ~/.pi/agent/themes/jp-tokyo-night-user-focus.json
```

El acceso, Git, sincronizacion y gates de la notebook viven solamente en `C:/dev/infra/docs/runbooks/notebook-operations.md`; las operaciones del VPS viven en `C:/dev/infra/docs/runbooks/vps-operations.md`. La evidencia consolidada de paridad, comandos, hashes, backups y rollback vive en `C:/dev/infra/docs/tracks/pi-host-runtime-parity-20260723.md`.

## `windows-input.ts`

Editor principal del prompt de Pi con semantica estilo Windows/VS Code. No es especifico de Windows como sistema operativo; deberia funcionar en Windows, Linux y macOS si el terminal entrega las teclas a Pi.

Atajos principales:

- `Ctrl+A`: seleccionar todo.
- `Shift+Arrow`: extender seleccion.
- `Ctrl+Shift+Left/Right`: extender seleccion por palabra.
- `Shift+Home/End` y `Ctrl+Shift+Home/End`: seleccionar hasta limites de linea/documento.
- `Ctrl+C`: copiar selección; sin selección delega a `app.clear` y limpia el prompt.
- `Ctrl+X`: cortar selección; sin selección no limpia el editor.
- `Ctrl+V`: intenta pegar texto del clipboard del sistema cuando Pi recibe la tecla; el pegado normal del terminal también funciona.
- escribir, pegar, `Backspace` y `Delete`: reemplazan/eliminan seleccion.

Comandos dentro de Pi:

```text
/windows-input status
/windows-input on
/windows-input off
/windows-input toggle
```

## Instalacion con scripts

### Windows PowerShell

Desde la raiz de este repo:

```powershell
./scripts/install-windows-input.ps1 -Status
./scripts/install-windows-input.ps1 -Scope Global
```

Si queres instalarla solo para este proyecto y remover la copia global para evitar doble carga:

```powershell
./scripts/install-windows-input.ps1 -Scope Project -RemoveGlobal
```

### Linux/macOS/Git Bash

Desde la raiz de este repo:

```bash
scripts/install-windows-input.sh --status
scripts/install-windows-input.sh --global
```

Si queres instalarla solo para este proyecto y remover la copia global para evitar doble carga:

```bash
scripts/install-windows-input.sh --project --remove-global
```

Luego abrir Pi o ejecutar `/reload` en una sesion existente.

## Instalacion manual equivalente

### Global recomendada

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.pi\agent\extensions" | Out-Null
Copy-Item .\pi-extensions\windows-input.ts "$env:USERPROFILE\.pi\agent\extensions\windows-input.ts" -Force
```

Linux/macOS:

```bash
mkdir -p ~/.pi/agent/extensions
cp pi-extensions/windows-input.ts ~/.pi/agent/extensions/windows-input.ts
```

### Project-local opcional

```bash
mkdir -p .pi/extensions
cp pi-extensions/windows-input.ts .pi/extensions/windows-input.ts
```

Usar project-local solo si no hay copia global activa o si se elimina la global.

## Linux: notas de compatibilidad

La seleccion y edicion funcionan igual si el terminal entrega las teclas a Pi. Las combinaciones problematicas suelen ser `Shift+Arrow` y `Ctrl+Shift+Arrow`, porque algunos terminales, multiplexores o escritorios las capturan.

Clipboard:

- Wayland: instalar `wl-clipboard` para `wl-copy` / `wl-paste`.
- X11: instalar `xclip`.
- En sesiones SSH/remotas, `Ctrl+C` usa OSC 52 cuando es posible para copiar al clipboard del terminal local. `Ctrl+V` normalmente depende de que el terminal pegue el texto hacia Pi; si Pi recibe literalmente `Ctrl+V`, solo puede leer clipboards accesibles desde la máquina donde corre Pi.
- Si no estan instalados o el terminal no permite clipboard remoto, la edicion/seleccion sigue funcionando, pero copiar/pegar puede quedar limitado al terminal.

Ejemplos:

```bash
# Debian/Ubuntu
sudo apt install wl-clipboard xclip

# Fedora
sudo dnf install wl-clipboard xclip

# Arch
sudo pacman -S wl-clipboard xclip
```

## Troubleshooting

- Si `/windows-input status` no existe, la extension no cargo: revisar ruta de instalacion y ejecutar `/reload`.
- Si aparecen comandos como `/windows-input:1`, probablemente hay copia global y project-local al mismo tiempo. Dejar solo una.
- Si `Shift+Arrow` no selecciona, revisar que el terminal o tmux/screen no capture esos atajos.
- Si selecciona pero no copia en Linux, instalar `wl-clipboard` o `xclip` segun corresponda.
- Si una actualizacion de Pi rompe el render/input, desactivar con `/windows-input off` o mover/eliminar el archivo instalado.
