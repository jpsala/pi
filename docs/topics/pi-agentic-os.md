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

## Uso En Pi

Aunque no exista `.pi/`, una sesion Pi puede trabajar con la capa AOS leyendo `AGENTS.md`, `docs/.generated/context-index.md` y `docs/WORKING_MEMORY.md`.

Si una decision humana bloquea, usar `ask_user` con pregunta corta, contexto y opciones.
