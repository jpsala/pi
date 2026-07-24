# AGENTS.md

Workspace `pi` de JP: laboratorio durable, portable y reversible para probar y mantener extensiones, hacks, APIs, Windows Input, footer/statusline y UX compacta.

## Lectura Inicial

1. `docs/.generated/context-index.md` si existe.
2. `docs/WORKING_MEMORY.md`.
3. `docs/TOPICS.md` o busqueda por triggers.
4. Topic, track, spec o codigo puntual segun el pedido.
5. `docs/README.md` solo si hace falta mapa documental.

No abrir docs largos ni crear estructura de producto: este workspace no es un runtime de producto.

## Reglas

- Responder en espanol por defecto.
- No inventar stack, comandos, deploy, datos ni decisiones: usar placeholders honestos hasta que el proyecto tenga contenido real.
- No commitear secretos, `.env`, bases locales, exports privados ni datos sensibles.
- No revertir cambios de usuario sin pedido explicito.
- La memoria durable vive en `docs/`; no usar chats como fuente de verdad.
- Para cada experimento Pi relevante, persistir paquete/version, estado, fuentes/patches/configs saneadas, scripts/toggles, API/cache si aplica, backup, smoke, riesgos y rollback suficientes para reproducirlo o volver atras.
- `C:/dev/os` conserva `/flow`, routing e inventario global general; este repo registra las piezas Pi probadas o personalizadas aquí sin copiar secretos, `auth.json`, respuestas privadas de APIs ni `node_modules`.
- `C:/dev/infra/docs/runbooks/notebook-operations.md` es la autoridad para operar o sincronizar la notebook. Si JP menciona `notebook`, `note`, `ASUS` o `ssh notebook`, abrir ese runbook y conservar aca solo el puntero, sin duplicar inventario, acceso ni reglas de sync.
- Si aparecen archivos preexistentes de contexto, integrarlos, indexarlos, archivarlos o preguntar antes de borrarlos.
- Limitar `init/adopt/update/perfect os` a la capa agentica salvo pedido explicito.
- Para implementacion/review, `docs/topics/minimal-implementation.md` es politica liviana opcional: reusar lo existente y evitar dependencias/boilerplate innecesarios; Ponytail no es obligatorio ni dependencia local.

## Web, Internet E Instalaciones

- Usar web/internet libremente por defecto cuando conocimiento externo o cambiante evite adivinar: docs oficiales, releases, issues/source, metadata de paquetes, errores, APIs y comparativas. No enviar secretos, `.env`, codigo privado sensible, datos personales ni credenciales a servicios externos.
- Si evidencia online contradice el repo local, docs del proyecto o comportamiento observado, consultar a JP antes de decidir; presentar ambas evidencias, fuentes e impacto practico.
- Antes de instalar dependencias, CLIs globales, paquetes de sistema, herramientas de package-manager o binarios/scripts remotos, pedir autorizacion explicita con comando exacto, alcance, motivo, riesgos, alternativa, cambios esperados y rollback. Tratar `curl | sh`/scripts remotos como alto riesgo y preferir alternativas auditables.

## Comandos AOS

- `/flow` es la única entrada diaria: `Pensar | Planear | Hacer | Cerrar`.
- Planear declara `execution_route: economical | balanced | strong`; Hacer aplica esa ruta (`balanced` por defecto) y bloquea sin fallback si falta modelo o auth.
- Hacer abre una sesión nueva enlazada con handoff documental revisable y ejecuta directamente allí, sin Agent ni auto-send; Cerrar es opcional si Hacer ya persistió el estado y `/new` queda para sesiones manuales.
- `realinear os` / `aos-realinear-os` abre `docs/topics/agentic-os-operations.md`; perfect/init/adopt/update/align son operaciones manager-only desde `C:/dev/os`.
- No mantener prompts de lifecycle, motores alternativos ni una copia local de `/flow`.

## Comandos De Contexto

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
```
