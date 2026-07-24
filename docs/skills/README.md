# Skills Locales

Este workspace no mantiene copias de skills AOS manager-only. El lifecycle diario
usa el `/flow` global de `C:/dev/os`; init/adopt/update/align/perfect/realinear se
ejecutan desde el manager cuando corresponda.

`docs/skills/` queda como canon vacío para futuras skills realmente específicas
de las customizaciones Pi de este repo. `.agents/skills` puede seguir como
junction técnico hacia este directorio; no copiar aquí skills upstream para
hacerlas visibles.

Las capacidades propias de este repo viven en código y topics:

- `pi-extensions/windows-input.ts` y sus instaladores;
- snapshots/restauradores de footer, statusline y UX;
- `docs/topics/windows-input-extension.md`;
- `docs/topics/pi-statusline-customization.md`;
- `docs/topics/pi-extension-stack.md`.

Después de agregar una skill local legítima:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```
