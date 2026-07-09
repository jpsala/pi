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
- `.agents/skills` es compatibilidad tecnica por junction/toggle/symlink local.
- Estado actual: `.agents/skills` es un adapter local ignorado por git y puede estar `disabled` (ausente) para reducir ruido en slash; habilitarlo con `scripts/ensure-skills-link.ps1`, `scripts/toggle-skills-link.ps1 on` o `/aos-skills on` si se necesita discovery.
- Los comandos canonicos usan directorios `aos-*`; directorios historicos sin prefijo pueden quedar solo como compatibilidad hasta limpieza confirmada.
- No duplicar skills en dos carpetas reales.

## Comandos

En Windows:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
```

En Linux/VPS sin PowerShell, crear/verificar symlink manual:

```bash
mkdir -p .agents
ln -sfn ../docs/skills .agents/skills
readlink .agents/skills
```

Tras modificar skills:

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```
## Dynamic Workflows Pilot

- `aos-dynamic-workflows-pilot/`: piloto opt-in para comparar `pi-dynamic-workflows` contra `taskflow` sin volverlo default.
- `.agents/skills` se mantiene como compatibility path estable; no borrarlo para limpiar slash porque algunos hosts cachean paths.
