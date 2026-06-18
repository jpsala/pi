---
id: os-quality
status: active
kind: how-to
triggers:
  - perfect os
  - dejar en condiciones
  - calidad agentica
  - docs livianos
  - optimizar contexto
primary_refs:
  - docs/topics/agentic-os-operations.md
  - docs/topics/docs-knowledge-system.md
  - scripts/context-index.ts
  - scripts/agent-context-audit.ts
---

# Calidad Agentica

## Objetivo

Que una sesion nueva pueda leer poco, entender el estado real y continuar sin inventar decisiones.

## Checklist

1. Hot path chico: `AGENTS.md`, indice, `WORKING_MEMORY.md`, `TOPICS.md`.
2. Topics con frontmatter, triggers y links desde `TOPICS.md`.
3. Tracks activas con estado y proximo paso.
4. Skills locales en `docs/skills/`; `.agents/skills` solo como junction opcional.
5. Adapters `.pi` y SpecKit instalados solo si aplican.
6. Audit verde.

## Cierre

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```
