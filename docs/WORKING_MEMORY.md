# Working Memory

Estado vivo del workspace `pi`. Mantener corto.

Ultima actualizacion manual: 2026-07-03.

## Lectura Rapida

| Area | Estado | Abrir primero | Siguiente accion |
| --- | --- | --- | --- |
| Proyecto | pending | `docs/PROJECT.md` | Definir proposito real antes de crear producto, runtime o deploy. |
| AOS | active | `docs/topics/agentic-os-operations.md` | Capa minima inicial instalada; completar contexto local cuando exista. |
| Documentacion | active | `docs/topics/docs-knowledge-system.md` | Mantener ruta caliente chica e indice regenerado. |
| Skills locales | available | `docs/topics/local-codex-skills.md` | `docs/skills/` es canon; `.agents/skills` existe como symlink local ignorado por git. |
| Pi local | active | `docs/topics/pi-agentic-os.md` | Windows Pi alineado con `jpsal@192.168.100.8`; mantener `.pi/` y config global como capa agentica local. |
| PI WEB VPS | active | `docs/topics/pi-agentic-os.md#pi-web-en-vps`, `C:\dev\infra\docs\runbooks\vps-operations.md` | Publicado en `https://pi.jpsala.dev` con Cloudflare Access `JP only`; SSH tunnel queda como fallback. |
| Windows input | active | `docs/topics/windows-input-extension.md` | Probar `/windows-input status` y selección con `Shift+Arrow` / `Ctrl+Shift+Arrow` tras `/reload`. |
| Pi statusline | active | `docs/topics/pi-statusline-customization.md` | Config compacta guardada en `pi-extensions/pi-footer.json`; restaurar/replicar con `scripts/apply-pi-statusline-customization.ps1` (Windows) o `.sh` (Linux/VPS). |

## Estado Actual

- Init OS aplicado sobre carpeta vacia/no git.
- No se detecto stack, README de producto, scripts, datos ni deploy.
- Adapter `.agents/skills` esta presente como symlink local ignorado por git.
- Adapter Pi `.pi/` instalado localmente con prompts/comandos AOS y extensiones de soporte, copiado desde `jpsal@192.168.100.8` el 2026-06-20.
- Extensión global `windows-input.ts` instalada en `C:\Users\jpsal\.pi\agent\extensions\windows-input.ts`; copia fuente versionable en `pi-extensions/windows-input.ts`, instrucciones en `pi-extensions/README.md` e instaladores `scripts/install-windows-input.sh` / `scripts/install-windows-input.ps1`. Reemplaza el prompt principal de Pi con un `CustomEditor` estilo Windows/VS Code. Comandos: `/windows-input status|on|off|toggle`; usar `/reload` en sesiones abiertas.
- Statusline compacta de JP guardada: `pi-extensions/pi-footer.json`, topic `docs/topics/pi-statusline-customization.md`, restauradores `scripts/apply-pi-statusline-customization.ps1` / `.sh`. Incluye parches locales para `pi-footer` (filtra duplicado `Codex 5h NN% 7d NN%`), `pi-chrome` (`chrome:∞`) y `pi-codex-usage` (`5h:86% · 7d:33% · ↺7d:3d0h`, sin publicar el status completo duplicado). Validado en `C:\dev\dictation-tauri`; aplicar tambien en VPS con script `.sh`. Reaplicar tras actualizar extensiones y luego `/reload`.
- PI WEB remoto debe consultarse en `C:\dev\infra`: VPS `vps`, servicios user `pi-web.service`/`pi-web-sessiond.service`, bind `127.0.0.1:8504`, publicado como `https://pi.jpsala.dev` con Cloudflare Access `JP only`; SSH tunnel queda como fallback. Default Pi global en Windows y VPS: `openai-codex/gpt-5.5` con thinking `high`; no volver a `openrouter/z-ai/glm-5.2` salvo pedido explicito. Para UX local/browser: `pi-tool-display`, `pi-hide-messages` y `@firstpick/pi-package-webui`; aplicar configs/parche con `scripts/apply-pi-webui-ux.ps1` o `.sh`.

## Riesgos

- No inventar el proposito del workspace.
- No agregar dependencias ni runtime externo sin confirmacion.
- No guardar secretos ni datos sensibles.
- `windows-input.ts` usa internals de Pi; si una actualización rompe selección/render, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`. No es OS-specific: en Linux depende de que el terminal pase las teclas y de `wl-copy`/`xclip` para clipboard.
- No duplicar `windows-input.ts` en `.pi/extensions/` mientras exista globalmente, para evitar comandos sufijados y doble reemplazo del editor.

## Proximo Paso Probable

Si JP pide instalar `windows-input` en otra PC: abrir `docs/topics/windows-input-extension.md` y `pi-extensions/README.md`; ejecutar `scripts/install-windows-input.sh --global` en Linux/macOS/Git Bash o `./scripts/install-windows-input.ps1 -Scope Global` en PowerShell; luego pedir/ejecutar `/reload` en Pi y verificar `/windows-input status`.
- Continuidad Pi 2026-07-04: JP guarda primero con `/aos-guardar-sesion`; luego `/aos-continuar [objetivo]` es el unico comando para abrir sesion nueva con prompt de continuidad desde docs vivos. `--preview` permite revisar antes de enviar.
