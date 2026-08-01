---
id: wezterm-attention
status: active
kind: reference
triggers:
  - wezterm attention
  - tabs pi
  - pi esperando pregunta
  - indicador pi
  - ask_user tab
primary_refs:
  - ../../pi-extensions/wezterm-attention-bridge.ts
  - C:/dev/wizterm/config/plugins.lua
  - C:/Users/jpsal/.pi/agent/settings.json
---

# WezTerm Attention para Pi

## Estado

Activo desde 2026-07-31.

- Writer Pi: paquete global `git:github.com/pro-vi/wezterm-attention`, probado con Pi `0.83.0`.
- Bridge propio: `pi-extensions/wezterm-attention-bridge.ts`, instalado globalmente en `~/.pi/agent/extensions/`.
- Renderer WezTerm: implementación local en `C:/dev/wizterm/config/plugins.lua`; no usa el renderer Lua upstream.
- Backup de instalación: `~/.pi/agent/backups/wezterm-attention-20260731-183913/`.

## Comportamiento

| Estado | Tab |
| --- | --- |
| Tab activa sin otro estado | `▶` y fondo azul |
| Pi trabajando | `●` violeta; conserva `▶` si además está activa |
| `ask_user` o `ask_user_question` esperando respuesta | `!` rojo |
| Pi terminó | `✓` verde |
| Tab terminada o esperando recibe foco | el marcador se reconoce y limpia |

El paquete upstream escribe JSON por pane en `~/.local/state/wezterm-attention/`. El bridge emite `notify` desde `tool_call`, después de que el writer publicó `thinking`, y vuelve a `thinking` en `tool_result` hasta `agent_settled`.

## Por qué hay renderer local

El writer Pi generó correctamente los marcadores, pero el renderer/cache Lua upstream no reflejó el cambio de forma fiable en la ventana WezTerm existente. El renderer local lee los archivos pequeños durante `format-tab-title`, valida TTL y usa un `update-status` vacío para invalidar la barra mientras Pi espera sin producir output.

## Recarga correcta

Son dos runtimes distintos:

- `/reload` dentro de Pi recarga el writer y el bridge Pi.
- **WezTerm: reload configuration** o reiniciar WezTerm carga `config/plugins.lua`.

Un `/reload` de Pi por sí solo no actualiza la configuración visual de WezTerm.

## Smoke verificado

Se abrió un proceso WezTerm aislado con la configuración actual y un marcador sintético. La barra mostró `1: ● wezterm` con fondo violeta. El proceso de smoke y sus archivos temporales se retiraron después de la prueba.

El 2026-07-31 también se verificó el handoff operativo: desde pane `14` se creó pane `80`, ambos en window `0` y en tabs distintos; Pi respondió correctamente con Unicode desde `C:/dev/pi`.

## Handoff Pi En Un Tab Existente

Para un handoff pedido por JP, abrir un tab en la ventana WezTerm actual, no Windows Terminal ni otra ventana. Nombrarlo `<proyecto> · <tarea corta>`:

```powershell
$sourcePane = $env:WEZTERM_PANE
$newPane = wezterm cli spawn --pane-id $sourcePane --cwd C:\dev\<repo> -- `
  "C:\Program Files\nodejs\node.exe" `
  "C:\Program Files\nodejs\node_modules\@earendil-works\pi-coding-agent\dist\cli.js" `
  --name "<tarea>" "<prompt>"
wezterm cli set-tab-title --pane-id $newPane "<proyecto> · <tarea corta>"
```

`spawn` devuelve el pane nuevo. Corroborar con `wezterm cli list --format json` que origen y destino comparten `window_id`, tienen distinto `tab_id` y usan el cwd correcto; `wezterm cli get-text --pane-id <nuevo>` permite verificar el texto. Si no existe `WEZTERM_PANE`, resolver explícitamente `--window-id` y no adivinar entre varias ventanas. La referencia canónica ampliada de esta PC vive en `C:/dev/wezterm/docs/topics/wezterm-config.md`.

## Instalación y rollback

Instalación global del writer:

```powershell
pi install git:github.com/pro-vi/wezterm-attention
Copy-Item C:\dev\pi\pi-extensions\wezterm-attention-bridge.ts `
  $env:USERPROFILE\.pi\agent\extensions\wezterm-attention-bridge.ts -Force
```

Rollback Pi:

```powershell
Remove-Item $env:USERPROFILE\.pi\agent\extensions\wezterm-attention-bridge.ts -Force
pi remove git:github.com/pro-vi/wezterm-attention
```

Rollback visual: retirar `require('config.plugins').apply_to_config(config)` de `C:/dev/wizterm/wezterm.lua` y recargar o reiniciar WezTerm. No eliminar procesos/tabs abiertos para probar una recarga.
