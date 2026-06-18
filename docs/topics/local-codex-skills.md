---
id: local-codex-skills
status: reference
kind: how-to
triggers:
  - skills
  - comandos locales
  - slash commands
  - docs/skills
  - .agents/skills
primary_refs:
  - docs/skills/
  - scripts/ensure-skills-link.ps1
  - scripts/toggle-skills-link.ps1
---

# Skills Locales

## Regla

- `docs/skills/` es la fuente canonica versionada.
- `.agents/skills` es compatibilidad tecnica por junction/toggle.
- No duplicar skills en dos carpetas reales.

## Comandos

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
```

Tras modificar skills:

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```
