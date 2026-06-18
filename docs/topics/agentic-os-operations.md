---
id: agentic-os-operations
status: active
kind: how-to
triggers:
  - init os
  - adopt os
  - update os
  - realinear os
  - perfect os
primary_refs:
  - AGENTS.md
  - docs/WORKING_MEMORY.md
  - docs/TOPICS.md
  - docs/topics/os-quality.md
  - scripts/context-index.ts
  - scripts/agent-context-audit.ts
---

# Operaciones Agentic OS

## Uso

Usar para crear, adoptar, actualizar o auditar la capa agentica de este workspace.

## Reglas

- No inventar proposito, stack, comandos, deploy ni datos.
- Preservar memoria local; preguntar antes de borrar o reemplazar contenido dudoso.
- Limitar cambios a la capa agentica salvo pedido explicito.
- Regenerar indice y correr audit despues de cambios OS.

## Init OS

Estado aplicado: carpeta vacia/no git inicializada con AOS minimo.

Checklist futuro:

1. Leer destino y detectar stack/docs existentes.
2. Crear estructura minima con placeholders honestos.
3. Agregar adapters solo si aplican o JP los pide.
4. Ejecutar `bun scripts/context-index.ts`.
5. Ejecutar `bun scripts/agent-context-audit.ts`.

## Update / Adopt

Cuando exista contenido local, fusionar contra el kit canonico sin pisar `WORKING_MEMORY`, decisiones, tracks ni topics locales.
