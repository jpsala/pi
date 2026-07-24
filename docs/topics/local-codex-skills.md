---
id: local-codex-skills
status: reference
kind: decision-map
triggers:
  - skills locales
  - local skills
  - docs/skills
  - .agents/skills
  - pasar a skills
  - promover a skill
primary_refs:
  - docs/skills/README.md
  - docs/skills/
  - AGENTS.md
  - scripts/ensure-skills-link.ps1
  - scripts/toggle-skills-link.ps1
---

# Skills Locales De Codex

Este workspace no copia skills AOS manager-only. Se consultan y ejecutan desde
`C:/dev/os`; `/flow` cubre el lifecycle diario. `docs/skills/` queda reservado
para acciones repetibles y específicas de Windows Input, footer/statusline o UX
propias de este repo.

## Skill, Topic O Regla

| Tipo | Usar cuando |
| --- | --- |
| Regla activa | Debe condicionar todo trabajo y no es un comando. |
| Topic | Es conocimiento o criterio recuperable bajo demanda. |
| Skill | Es una acción local, repetible, estable y con triggers claros. |
| Track | Es trabajo vivo con estado y próximo paso. |

Antes de crear una skill, confirmar que no sea manager-only, que no exista en
`C:/dev/os`, que tenga consumidor local real y que su metadata justifique el
costo de descubrimiento. Preferir `SKILL.md` corto que apunte a topic o script
canónico.

`.agents/skills` es sólo compatibilidad técnica hacia `docs/skills/`; puede
permanecer aunque el canon local esté vacío. No usar toggles para copiar o
restaurar las 20 skills legacy retiradas.

## Validación

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

Si se crea una skill local legítima, indexarla en `docs/skills/README.md` y
mantener cualquier metadata UI alineada. El lifecycle AOS, operaciones de flota
y decisiones globales siguen perteneciendo a `C:/dev/os`.
