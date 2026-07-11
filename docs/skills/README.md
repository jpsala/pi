# Skills Locales

`docs/skills/` es la fuente canonica de las skills locales del repo.

## Regla

- Las skills AOS portables canonicas viven upstream en `C:/dev/os/docs/skills/`; no duplicarlas localmente.
- `docs/skills/` conserva solo superficie local no colisionante (incluidos aliases legacy que Pi aun pueda descubrir).
- `.agents/skills` existe solo como compatibilidad tecnica y apunta por junction a la superficie local cuando esta no esta vacia.
- Si una regla propia de Pi cambia, documentarla en los topics locales; no forkear una skill portable para conservarla.

## Contenido Actual

- Las skills operativas AOS (`aos-*`) se consultan en `C:/dev/os/docs/skills/`.
- La superficie local restante contiene solo aliases legacy no colisionantes para discovery compatible.
- `/aos-continuar` vive en el adapter Pi (`.pi/extensions/aos-tools.ts`): abre sesion nueva con prompt de continuidad despues de que JP guardo sesion.

Las herramientas Pi de pensamiento/implementacion (`taskflow`, `pi-code-planner`, `pi-task`, `advisor`, Ponytail, `dgoal`, `context-viewer`, `pi-lens`) se documentan en `docs/topics/pi-extension-stack.md` y en `C:/dev/os`, no como skills locales separadas.

## Validacion

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
python C:\dev\agent-infra\rules\skills\.system\skill-creator\scripts\quick_validate.py C:/dev/os/docs/skills/<nombre>
bun run context:index
bun run context:audit
```

## Mantenimiento

- Si una skill nueva usa metadata UI, crear o regenerar `agents/openai.yaml`.
- Si un doc humano apunta a `.agents/skills` como fuente de verdad, corregirlo a `docs/skills/`.
- Si Codex deja de descubrir skills, reparar primero la junction antes de tocar contenido: `bun run skills:on`.
- Si Pi muestra demasiadas skills en `/`, no borrar el junction: Pi/Codex pueden cachear paths; `off`/`toggle` son aliases legacy no destructivos.
- Tras mover o portar el repo a otro disco, correr `scripts/ensure-skills-link.ps1`: si encuentra una carpeta real en `.agents/skills`, la mueve a backup, fusiona items faltantes hacia `docs/skills/` y recrea el junction sin perder contenido.

## Aplicar En Otros Repos

- Copiar o fusionar `docs/skills/` como parte de AOS cuando el repo destino necesite slash commands locales.
- No copiar `.agents/skills` como carpeta real; recrearla en destino con `scripts/ensure-skills-link.ps1`. Si el port ya trajo una carpeta real, el script la preserva como `.agents/skills.backup-*` y copia skills faltantes al canon.
- Mantener las skills hibridas: metadata y cuerpo corto en la skill, procedimiento durable en topics, scripts o docs canonicos del repo destino.
