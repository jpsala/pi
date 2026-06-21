# Skills Locales

`docs/skills/` es la fuente canonica de skills portables para este workspace.

## Regla

- `.agents/skills` es solo compatibilidad tecnica por junction/toggle/symlink local.
- No duplicar una carpeta real en `.agents/skills`.
- Estado actual: `.agents/skills` existe como symlink local ignorado por git hacia `docs/skills/`; no guardar contenido durable alli.

## Contenido Inicial

Skills operativas AOS copiadas/adaptadas desde el kit canonico:

- `os-help`, `init-os`, `adopt-os`, `update-os`, `align-os-project`, `perfect-os`, `realinear-os`.
- `sigamos`, `gol-lite`, `guardar-sesion`, `nueva-sesion`, `nueva-sesion-con-gol`.
- Aliases legacy: `checkpoint`, `cerrar-sesion`, `continuar-sesion`, `continuar-sesion-con-gol`.
- `evaluar-skills`, `repo-commit-push`.

No se copiaron skills pesadas/opcionales como `impeccable` ni `speckit-*` porque el workspace todavia no tiene producto UI ni specs.

## Validacion

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

## Orquestacion

- `aos-orquestar/`: proponer o ejecutar un fan-out controlado con threads/subagentes AOS.
- `aos-fanout/`: alias intensivo para usar todos los threads/subagentes seguros y volver a serial cuando no conviene.
