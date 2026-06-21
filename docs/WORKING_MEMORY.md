# Working Memory

Estado vivo del workspace `pi`. Mantener corto.

Ultima actualizacion manual: 2026-06-21.

## Lectura Rapida

| Area | Estado | Abrir primero | Siguiente accion |
| --- | --- | --- | --- |
| Proyecto | pending | `docs/PROJECT.md` | Definir proposito real antes de crear producto, runtime o deploy. |
| AOS | active | `docs/topics/agentic-os-operations.md` | Capa minima inicial instalada; completar contexto local cuando exista. |
| Documentacion | active | `docs/topics/docs-knowledge-system.md` | Mantener ruta caliente chica e indice regenerado. |
| Skills locales | available | `docs/topics/local-codex-skills.md` | `docs/skills/` es canon; `.agents/skills` existe como symlink local ignorado por git. |
| Pi local | active | `docs/topics/pi-agentic-os.md` | Windows Pi alineado con `jpsal@192.168.100.8`; mantener `.pi/` y config global como capa agentica local. |
| Windows input | active | `docs/topics/windows-input-extension.md` | Probar `/windows-input status` y selección con `Shift+Arrow` / `Ctrl+Shift+Arrow` tras `/reload`. |

## Estado Actual

- Init OS aplicado sobre carpeta vacia/no git.
- No se detecto stack, README de producto, scripts, datos ni deploy.
- Adapter `.agents/skills` esta presente como symlink local ignorado por git.
- Adapter Pi `.pi/` instalado localmente con prompts/comandos AOS y extensiones de soporte, copiado desde `jpsal@192.168.100.8` el 2026-06-20.
- Extensión global `windows-input.ts` instalada en `C:\Users\jpsal\.pi\agent\extensions\windows-input.ts`: reemplaza el prompt principal de Pi con un `CustomEditor` estilo Windows/VS Code. Comandos: `/windows-input status|on|off|toggle`; usar `/reload` en sesiones abiertas.

## Riesgos

- No inventar el proposito del workspace.
- No agregar dependencias ni runtime externo sin confirmacion.
- No guardar secretos ni datos sensibles.
- `windows-input.ts` usa internals de Pi; si una actualización rompe selección/render, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`.
- No duplicar `windows-input.ts` en `.pi/extensions/` mientras exista globalmente, para evitar comandos sufijados y doble reemplazo del editor.

## Proximo Paso Probable

Probar manualmente la extensión global en una sesión Pi nueva o tras `/reload`: `/windows-input status`, `Ctrl+A`, `Shift+Arrow`, `Ctrl+Shift+Left/Right`, copy/cut/paste sobre selección.
