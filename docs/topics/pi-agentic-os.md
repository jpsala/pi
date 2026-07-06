---
id: pi-agentic-os
status: reference
kind: how-to
triggers:
  - pi os
  - pi agentic os
  - os-sync
  - ask_user
  - /ask
  - /gol
  - /until-done
  - pi-web
  - pi web
  - web ui pi
  - vps pi web
  - web research
  - internet
  - instalar paquetes
  - instalar cli
primary_refs:
  - docs/OS_PLAYBOOK.md
  - docs/topics/agentic-os-operations.md
---

# Pi Agentic OS

## Web, Internet E Instalaciones

- Usar web/internet libremente por defecto cuando conocimiento externo o cambiante evite adivinar: documentacion oficial, changelogs/releases, issues/source, metadata de paquetes, errores, APIs, ejemplos y comparativas.
- Si evidencia online contradice el repo local, docs del proyecto o comportamiento observado, pausar y consultar a JP antes de decidir; presentar ambas evidencias con fuentes y el impacto practico.
- No enviar secretos, `.env`, codigo privado sensible, datos personales ni credenciales a servicios externos.
- Priorizar fuentes oficiales y citar fuentes cuando afecten decisiones tecnicas.
- Antes de instalar dependencias, CLIs globales, paquetes de sistema, herramientas de package-manager o binarios/scripts remotos, pedir autorizacion explicita con comando exacto, alcance, motivo, riesgos, alternativa, cambios esperados y rollback.
- Tratar `curl | sh`, binarios remotos y scripts de instalacion no auditados como alto riesgo; preferir package managers, checksums, docs oficiales o pasos inspeccionables.

## Estado

Adapter Pi local instalado en `.pi/` con prompts/comandos AOS y extensiones de soporte (`aos-tools.ts`, `aos-checkpoint-nudge.ts`). Extensión global adicional activa: `C:\Users\jpsal\.pi\agent\extensions\windows-input.ts`.

Configuracion global Pi de Windows alineada el 2026-06-20 con `jpsal@192.168.100.8`, realineada con VPS `vps-cf-jpsal` el 2026-06-29 y corregida el 2026-07-06:

- Proveedor/modelo por defecto en Windows y VPS: `openai-codex/gpt-5.5`, thinking `high`. Este default coincide con el modelo seleccionado en la sesion actual; no usar `openrouter/z-ai/glm-5.2` como default salvo pedido explicito.
- Tema `jp-tokyo-night-user-focus`, `powerline.enabled=false`, `defaultProjectTrust=always`.
- Paquetes activos historicos: `pi-rtk-optimizer`, `pi-codemapper`, `pi-minimal-subagent`, `pi-observational-memory`, `pi-web-access`, `pi-mcp-extension`, `pi-until-done`, `pi-chrome`, `pi-council`, `@llblab/pi-telegram`, `@calesennett/pi-codex-usage`, `@mporenta/pi-discord-remote`, `@juicesharp/rpiv-ask-user-question`, `@juicesharp/rpiv-i18n`, `@venthezone/picord`, `pi-ask-user`, `pi-footer`, `pi-agents-pool`.
- UX compacta agregada 2026-07-06 en Windows: `pi-tool-display`, `pi-hide-messages`, `@firstpick/pi-package-webui`, `pi-web-providers`, `@amaster.ai/pi-image-gen`. Config versionada en `pi-extensions/pi-tool-display.json` y `pi-extensions/pi-hide-messages.json`; reaplicar con `scripts/apply-pi-webui-ux.ps1` o `.sh`.
- Recursos globales copiados: `AGENTS.md`, `keybindings.json`, `mcp.json`, `models.json`, `telegram.json`, configs de `pi-footer` y `pi-rtk-optimizer`, prompt `codex-usage`, tema `jp-tokyo-night-user-focus`.
- `cm.exe` copiado a `~/.local/bin` y disponible en PATH.
- Extensión global `windows-input.ts`: input principal estilo Windows/VS Code mediante `CustomEditor`; comandos `/windows-input status|on|off|toggle`; status footer `win-input`.
- Statusline compacta de JP: ver `docs/topics/pi-statusline-customization.md`; snapshot `pi-extensions/pi-footer.json`; restaurar/replicar con `scripts/apply-pi-statusline-customization.ps1`.

Repo remoto publico: `https://github.com/jpsala/pi`.

## Extension Windows Input

Archivo activo global:

```text
C:\Users\jpsal\.pi\agent\extensions\windows-input.ts
```

Resumen:

- Se carga automáticamente para todos los proyectos desde `~/.pi/agent/extensions/`.
- En sesiones existentes, usar `/reload` para recargar.
- Agrega selección/edición en el prompt principal: `Ctrl+A`, `Shift+Arrow`, `Ctrl+Shift+Arrow`, `Shift+Home/End`, copy/cut/delete/paste sobre selección.
- Se puede alternar con `/windows-input on|off|toggle|status`.

Limitaciones y cuidado:

- Sólo reemplaza el editor principal de prompts en TUI; no cubre dialogs/selectores/overlays ni selección de mouse.
- Usa internals JS del editor de Pi; ante problemas, desactivar con `/windows-input off` o mover el archivo fuera de `~/.pi/agent/extensions/`.
- No duplicar en `.pi/extensions/` mientras exista globalmente: Pi descubre extensiones globales y project-locales, y los comandos duplicados se sufijan (`/windows-input:1`).

Detalle recuperable: `docs/topics/windows-input-extension.md`.

## Uso En Pi

Aunque no exista `.pi/`, una sesion Pi puede trabajar con la capa AOS leyendo `AGENTS.md`, `docs/.generated/context-index.md` y `docs/WORKING_MEMORY.md`.

Si una decision humana bloquea, usar `ask_user` con pregunta corta, contexto y opciones.

## VPS Mirror

El host SSH recomendado es `vps-cf-jpsal` (Cloudflare Access); `vps` directo puede timeoutear. Debe tener este workspace en `/home/jpsal/dev/pi`, equivalente Linux de `C:\dev\pi`.

Estado verificado y realineado el 2026-06-29 desde PC `asus`:

- Repo: `/home/jpsal/dev/pi` en `main`, remoto `https://github.com/jpsala/pi.git`, limpio en `origin/main`.
- Pi CLI de usuario: `~/.local/bin/pi` (`0.80.2`). `/usr/bin/pi` puede existir viejo (`0.79.6`), por eso `~/.zshenv` mantiene `~/.local/bin` y `~/.bun/bin` antes en `PATH` incluso para SSH no interactivo.
- Bun/Node/Ripgrep/CodeMapper disponibles: `bun`, `node`, `rg`, `cm`.
- Config Pi alineada con Windows salvo diferencias OS-specific:
  - `defaultProvider=openai-codex`, `defaultModel=gpt-5.5`, `defaultThinkingLevel=high`; corregido/verificado el 2026-07-06 despues de detectar que Windows/VPS habian quedado temporalmente en `openrouter/z-ai/glm-5.2`.
  - `theme=jp-tokyo-night-user-focus`, `hideThinkingBlock=true`, `powerline.enabled=false`.
  - paquetes principales: `pi-rtk-optimizer`, `pi-codemapper`, `pi-minimal-subagent`, `pi-observational-memory`, `pi-web-access`, `pi-mcp-extension`, `pi-until-done`, `pi-council`, `pi-telegram`, `pi-codex-usage`, `pi-discord-remote`, `rpiv-ask-user-question`, `rpiv-i18n`, `pi-ask-user`, `pi-footer`, `pi-agents-pool`, `pi-computer-use`. `pi-chrome` es OS/browser-specific y no debe sincronizarse al VPS salvo pedido explicito.
  - Recursos globales alineados: `AGENTS.md`, `settings.json`, `keybindings.json`, `models.json`, `mcp.json`, `telegram.json`, `pi-footer.json`, `pi-rtk-optimizer/config.json`, tema `jp-tokyo-night-user-focus`, `windows-input.ts`.
- Trust OS-specific: Windows usa `C:\dev`; VPS usa `/home/jpsal/dev`; no copiar `trust.json` literal.
- MCP `ahk` apunta a rutas Windows/AutoHotkey y no se espera que funcione en Linux; dejarlo como diferencia OS-specific salvo pedido explicito.
- Backup de configs previas en VPS: `~/.pi/agent/backup-align-from-asus-20260628-233918`.

Comandos de verificacion en VPS:

```bash
ssh vps-cf-jpsal 'cd /home/jpsal/dev/pi && git status --short --branch && pi --version && bun scripts/agent-context-audit.ts && cm stats'
ssh vps-cf-jpsal 'pi list | tail -40'
```

## PI WEB En VPS

Fuente de verdad operativa: `C:\dev\infra`, especialmente:

- `C:\dev\infra\docs\WORKING_MEMORY.md`
- `C:\dev\infra\docs\runbooks\vps-operations.md`
- `C:\dev\infra\docs\runbooks\automations-agents.md#pi-web-en-vps`
- `C:\dev\infra\docs\INVENTORY.md`

Estado documentado en `infra` el 2026-07-01:

- El paquete correcto para UI web remota persistente de Pi en el VPS es `@jmfederico/pi-web`; no confundir con `pi-web-access`, que solo agrega tools de búsqueda/fetch web para Pi. `@firstpick/pi-package-webui` es una WebUI companion por sesión/RPC; útil localmente, pero no reemplaza el servicio persistente del VPS sin rediseñar publicación/tunnel.
- PI WEB está instalado en el VPS como usuario `jpsal`, con paquete `@jmfederico/pi-web` versión `1.202606.7`.
- Corre como servicios systemd user: `pi-web.service` y `pi-web-sessiond.service`.
- Config remota: `/home/jpsal/.config/pi-web/config.json`.
- Bind esperado/verificado: `127.0.0.1:8504` solamente. No exponer directo a internet ni mover a `0.0.0.0`.
- Publicacion browser: `https://pi.jpsala.dev` via Cloudflare tunnel `constelaciones-pi-console` + Cloudflare Access app `PI WEB`, policy `JP only`.
- Fallback desde Windows/local: `ssh -L 8504:127.0.0.1:8504 vps`, luego abrir `http://127.0.0.1:8504`.
- Checks seguros:

```bash
ssh vps 'pi-web status'
ssh vps 'pi-web doctor'
ssh vps 'curl -fsS http://127.0.0.1:8504/api/pi-web/version'
ssh vps 'ss -ltnp | grep 8504 || true'
curl -I https://pi.jpsala.dev/
curl -sS https://pi.jpsala.dev/.well-known/cloudflare-access-protected-resource/
```

Guardrail: cambiar PI WEB, su hostname, tunnel, reverse proxy, bind o Access policy requiere aprobación explícita porque la UI permite operar sesiones Pi con acceso a repos, comandos y credenciales del VPS.

