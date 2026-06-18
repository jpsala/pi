---
name: align-os-project
description: Update and audit one or more registered AOS projects against this canonical kit, then verify that their local content still matches the OS vision. Use when JP says `align os project`, `alinear proyecto os`, `auditar proyecto registrado`, `actualizar y alinear project-id`, or wants confidence that a registered project has current OS mechanics and aligned docs.
---

# Align OS Project

Alinear un proyecto registrado con el AOS canonico.

Fuentes canonicas:

- `docs/OS_PROJECTS.md`
- `docs/topics/os-project-registry.md`
- `docs/topics/agentic-os-operations.md`
- `docs/topics/os-quality.md`
- `docs/OS_PLAYBOOK.md`

## Flujo

1. Leer `docs/OS_PROJECTS.md` y ubicar el/los `project-id` pedidos.
2. Verificar path, git status y capas OS baratas del target. Si el path falta, bloquear y pedir correccion.
3. Si hay varios candidatos o capas ambiguas, en Pi preferir `ask_user`/Glimpse multi-select.
4. Hacer backup/stash o confirmar antes de cambios riesgosos segun el estado del target.
5. Ejecutar el pase mecanico: `update os` si ya es AOS; `adopt os` si es candidato; para `scratch`, aplicar solo capa minima si JP lo pidio.
6. Ejecutar el pase de vision: `perfect os`/`docs/topics/os-quality.md` para revisar liviandad, memoria durable, topics, tracks, comandos, adapters y ausencia de placeholders/transcripts.
7. Regenerar indice y correr audit en el target si los scripts existen.
8. Actualizar `docs/OS_PROJECTS.md` con fecha, capas detectadas y proximo paso.
9. Reportar por proyecto: aplicado, omitido, conflictos, decisiones locales preservadas, drift restante, checks ejecutados.

## Guardrails

- No tocar producto, datos privados, deploy ni runtime salvo pedido explicito.
- No pisar `WORKING_MEMORY.md`, decisions, tracks, topics locales ni reglas de `AGENTS.md` sin fusion.
- No borrar memoria dudosa: integrar, archivar con estado claro o preguntar.
- No convertir workspaces `scratch` en fuente durable salvo que JP diga promover/guardar.
