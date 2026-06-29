---
id: pi-agentic-os
status: reference
kind: how-to
triggers:
  - pi os
  - pi agentic os
  - os-sync
  - ask_user
  - /ask
  - /gol
  - /until-done
primary_refs:
  - docs/OS_PLAYBOOK.md
  - docs/topics/agentic-os-operations.md
---

# Pi Agentic OS

## Estado

Adapter Pi local instalado en `.pi/` con prompts/comandos AOS y extensiones de soporte (`aos-tools.ts`, `aos-checkpoint-nudge.ts`). Extensión global adicional activa: `C:\Users\jpsal\.pi\agent\extensions\windows-input.ts`.

Configuracion global Pi de Windows alineada el 2026-06-20 con `jpsal@192.168.100.8` y realineada con VPS `vps-cf-jpsal` el 2026-06-29:

- Pi CLI `0.79.8`, proveedor/modelo por defecto `openai-codex/gpt-5.5`, thinking `high`.
- Tema `jp-tokyo-night-user-focus`, `powerline.enabled=false`, `defaultProjectTrust=always`.
- Paquetes activos: `pi-rtk-optimizer`, `pi-codemapper`, `pi-minimal-subagent`, `pi-observational-memory`, `pi-web-access`, `pi-mcp-extension`, `pi-until-done`, `pi-chrome`, `pi-council`, `@llblab/pi-telegram`, `@calesennett/pi-codex-usage`, `@mporenta/pi-discord-remote`, `@juicesharp/rpiv-ask-user-question`, `@juicesharp/rpiv-i18n`, `@venthezone/picord`, `pi-ask-user`, `pi-footer`, `pi-agents-pool`.
- Recursos globales copiados: `AGENTS.md`, `keybindings.json`, `mcp.json`, `models.json`, `telegram.json`, configs de `pi-footer` y `pi-rtk-optimizer`, prompt `codex-usage`, tema `jp-tokyo-night-user-focus`.
- `cm.exe` copiado a `~/.local/bin` y disponible en PATH.
- Extensión global `windows-input.ts`: input principal estilo Windows/VS Code mediante `CustomEditor`; comandos `/windows-input status|on|off|toggle`; status footer `win-input`.

Repo remoto publico: `https://github.com/jpsala/pi`.

## Extension Windows Input

Archivo activo global:

```text
C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
```

Resumen:

- Se carga automáticamente para todos los proyectos desde `~/.pi/agent/extensions/`.
- En sesiones existentes, usar `/reload` para recargar.
- Agrega selección/edición en el prompt principal: `Ctrl+A`, `Shift+Arrow`, `Ctrl+Shift+Arrow`, `Shift+Home/End`, copy/cut/delete/paste sobre selección.
- Se puede alternar con `/windows-input on|off|toggle|status`.

Limitaciones y cuidado:

- Sólo reemplaza el editor principal de prompts en TUI; no cubre dialogs/selectores/overlays ni selección de mouse.
- Usa internals JS del editor de Pi; ante problemas, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`.
- No duplicar en `.pi/extensions/` mientras exista globalmente: Pi descubre extensiones globales y project-locales, y los comandos duplicados se sufijan (`/windows-input:1`).

Detalle recuperable: `docs/topics/windows-input-extension.md`.

## Uso En Pi

Aunque no exista `.pi/`, una sesion Pi puede trabajar con la capa AOS leyendo `AGENTS.md`, `docs/.generated/context-index.md` y `docs/WORKING_MEMORY.md`.

Si una decision humana bloquea, usar `ask_user` con pregunta corta, contexto y opciones.

## VPS Mirror

El host SSH recomendado es `vps-cf-jpsal` (Cloudflare Access); `vps` directo puede timeoutear. Debe tener este workspace en `/home/jpsal/dev/pi`, equivalente Linux de `C:\dev\pi`.

Estado verificado y realineado el 2026-06-29 desde PC `asus`:

- Repo: `/home/jpsal/dev/pi` en `main`, remoto `https://github.com/jpsala/pi.git`, limpio en `origin/main`.
- Pi CLI de usuario: `~/.local/bin/pi` (`0.80.2`). `/usr/bin/pi` puede existir viejo (`0.79.6`), por eso `~/.zshenv` mantiene `~/.local/bin` y `~/.bun/bin` antes en `PATH` incluso para SSH no interactivo.
- Bun/Node/Ripgrep/CodeMapper disponibles: `bun`, `node`, `rg`, `cm`.
- Config Pi alineada con Windows salvo diferencias OS-specific:
  - `defaultProvider=openai-codex`, `defaultModel=gpt-5.5`, `defaultThinkingLevel=high`.
  - `theme=jp-tokyo-night-user-focus`, `hideThinkingBlock=true`, `powerline.enabled=false`.
  - paquetes principales: `pi-rtk-optimizer`, `pi-codemapper`, `pi-minimal-subagent`, `pi-observational-memory`, `pi-web-access`, `pi-mcp-extension`, `pi-until-done`, `pi-chrome`, `pi-council`, `pi-telegram`, `pi-codex-usage`, `pi-discord-remote`, `rpiv-ask-user-question`, `rpiv-i18n`, `pi-ask-user`, `pi-footer`, `pi-agents-pool`, `pi-computer-use`.
  - Recursos globales alineados: `AGENTS.md`, `settings.json`, `keybindings.json`, `models.json`, `mcp.json`, `telegram.json`, `pi-footer.json`, `pi-rtk-optimizer/config.json`, tema `jp-tokyo-night-user-focus`, `windows-input.ts`.
- Trust OS-specific: Windows usa `C:\dev`; VPS usa `/home/jpsal/dev`; no copiar `trust.json` literal.
- MCP `ahk` apunta a rutas Windows/AutoHotkey y no se espera que funcione en Linux; dejarlo como diferencia OS-specific salvo pedido explicito.
- Backup de configs previas en VPS: `~/.pi/agent/backup-align-from-asus-20260628-233918`.

Comandos de verificacion en VPS:

```bash
ssh vps-cf-jpsal 'cd /home/jpsal/dev/pi && git status --short --branch && pi --version && bun scripts/agent-context-audit.ts && cm stats'
ssh vps-cf-jpsal 'pi list | tail -40'
```
