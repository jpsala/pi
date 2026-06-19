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

Adapter `.pi/` no instalado en este init minimo. Agregarlo solo si este workspace necesita prompts/extensiones Pi propios.

Repo remoto publico: `https://github.com/jpsala/pi`.

## Uso En Pi

Aunque no exista `.pi/`, una sesion Pi puede trabajar con la capa AOS leyendo `AGENTS.md`, `docs/.generated/context-index.md` y `docs/WORKING_MEMORY.md`.

Si una decision humana bloquea, usar `ask_user` con pregunta corta, contexto y opciones.

## VPS Mirror

El host SSH `vps` debe tener este workspace en `/home/jpsal/dev/pi`, equivalente Linux de `C:\dev\pi`.

Estado verificado el 2026-06-18:

- Repo: `/home/jpsal/dev/pi` en `main`, remoto `https://github.com/jpsala/pi.git`.
- Pi CLI: usar `~/.local/bin/pi` (`0.79.7`) porque `/usr/bin/pi` era global npm `0.79.6` y no actualizable sin sudo.
- `PATH` esperado en VPS incluye `~/.local/bin` antes de `/usr/bin`.
- Bun/Node/Ripgrep/CodeMapper disponibles: `bun`, `node`, `rg`, `cm`.
- Config Pi alineada con Windows salvo diferencias OS-specific:
  - `defaultProvider=openai-codex`, `defaultModel=gpt-5.5`, `defaultThinkingLevel=high`.
  - `theme=tokyo-night-storm`, `hideThinkingBlock=true`, `powerline.enabled=false`.
  - paquetes principales: `pi-rtk-optimizer`, `pi-codemapper`, `pi-minimal-subagent`, `pi-observational-memory`, `pi-web-access`, `pi-mcp-extension`, `pi-until-done`, `pi-chrome`, `pi-council`, `pi-telegram`, `pi-codex-usage`, `pi-discord-remote`, `rpiv-ask-user-question`, `rpiv-i18n`, `picord`, `pi-ask-user`, `pi-footer`.
  - `~/.pi/agent/AGENTS.md` debe existir con la politica global local.
- Trust OS-specific: Windows usa `C:\dev`; VPS usa `/home/jpsal/dev`.
- MCP `ahk` apunta a rutas Windows/AutoHotkey y no se espera que funcione en Linux; dejarlo como diferencia OS-specific salvo pedido explicito.

Comandos de verificacion en VPS:

```bash
ssh vps 'cd /home/jpsal/dev/pi && git status --short --branch && pi --version && bun scripts/agent-context-audit.ts && cm stats'
```
