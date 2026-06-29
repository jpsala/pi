# Pi Extensions

Extensiones fuente para instalar en Pi en otras maquinas.

> Importante: los archivos fuente viven aca para ser portables. No se colocan en `.pi/extensions/` por defecto porque esa carpeta se auto-carga cuando el proyecto esta confiado. Si tambien existe una copia global, Pi puede cargar dos wrappers y crear comandos sufijados.

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

## `windows-input.ts`

Editor principal del prompt de Pi con semantica estilo Windows/VS Code. No es especifico de Windows como sistema operativo; deberia funcionar en Windows, Linux y macOS si el terminal entrega las teclas a Pi.

Atajos principales:

- `Ctrl+A`: seleccionar todo.
- `Shift+Arrow`: extender seleccion.
- `Ctrl+Shift+Left/Right`: extender seleccion por palabra.
- `Shift+Home/End` y `Ctrl+Shift+Home/End`: seleccionar hasta limites de linea/documento.
- `Ctrl+C` / `Ctrl+X`: copiar/cortar selección; sin selección no limpian el editor.
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
