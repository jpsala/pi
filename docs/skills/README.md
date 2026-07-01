# Skills Locales

`docs/skills/` es la fuente canonica de skills portables para este workspace.

## Regla

- `.agents/skills` es solo compatibilidad tecnica por junction/toggle/symlink local.
- No duplicar una carpeta real en `.agents/skills`.
- Estado actual: `.agents/skills` es un adapter local ignorado por git y puede estar `disabled` (ausente) para reducir ruido en slash; recrearlo con `scripts/ensure-skills-link.ps1`, `scripts/toggle-skills-link.ps1 on` o `/aos-skills on` cuando haga falta discovery.

## Contenido Inicial

Skills operativas AOS copiadas/adaptadas desde el kit canonico con prefijo canonico `aos-*`:

- `aos-help`, `aos-init-os`, `aos-adopt-os`, `aos-update-os`, `aos-align-os-project`, `aos-perfect-os`, `aos-realinear-os`.
- `aos-sigamos`, `aos-gol-lite`, `aos-guardar-sesion`, `aos-nueva-sesion`, `aos-nueva-sesion-con-gol`.
- Aliases legacy canonicos: `aos-checkpoint`, `aos-cerrar-sesion`, `aos-continuar-sesion`, `aos-continuar-sesion-con-gol`.
- `aos-orquestar`, `aos-fanout`, `aos-evaluar-skills`, `aos-repo-commit-push`.

Se conservan temporalmente directorios legacy sin prefijo (`os-help`, `init-os`, etc.) para compatibilidad local; no son la ruta canonica nueva.

No se copiaron skills pesadas/opcionales como `aos-impeccable` ni `aos-speckit-*` porque el workspace todavia no tiene producto UI ni specs activas.

## Validacion

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

## Orquestacion

- `aos-orquestar/`: proponer o ejecutar un fan-out controlado con threads/subagentes AOS.
- `aos-fanout/`: alias intensivo para usar todos los threads/subagentes seguros y volver a serial cuando no conviene.
