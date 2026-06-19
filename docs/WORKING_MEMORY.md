# Working Memory

Estado vivo del workspace `pi`. Mantener corto.

Ultima actualizacion manual: 2026-06-19.

## Lectura Rapida

| Area | Estado | Abrir primero | Siguiente accion |
| --- | --- | --- | --- |
| Proyecto | pending | `docs/PROJECT.md` | Definir proposito real antes de crear producto, runtime o deploy. |
| AOS | active | `docs/topics/agentic-os-operations.md` | Capa minima inicial instalada; completar contexto local cuando exista. |
| Documentacion | active | `docs/topics/docs-knowledge-system.md` | Mantener ruta caliente chica e indice regenerado. |
| Skills locales | available | `docs/topics/local-codex-skills.md` | `docs/skills/` es canon; `.agents/skills` existe como symlink local ignorado por git. |
| VPS mirror | active | `docs/topics/pi-agentic-os.md` | `/home/jpsal/dev/pi` debe espejar `C:\dev\pi`; revisar diferencias OS-specific antes de corregir. |

## Estado Actual

- Init OS aplicado sobre carpeta vacia/no git.
- No se detecto stack, README de producto, scripts, datos ni deploy.
- Adapter `.agents/skills` esta presente como symlink local ignorado por git; `.pi`, SpecKit y producto quedan omitidos hasta que JP los pida o el repo los necesite.

## Riesgos

- No inventar el proposito del workspace.
- No agregar dependencias ni runtime externo sin confirmacion.
- No guardar secretos ni datos sensibles.

## Proximo Paso Probable

Definir para que se usara `C:\dev\pi` y, segun eso, completar `docs/PROJECT.md`, `docs/DEVELOPMENT.md` y los topics necesarios.
