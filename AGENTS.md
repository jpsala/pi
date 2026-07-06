# AGENTS.md

Workspace `pi` de JP. Proposito del proyecto: pendiente de definir.

## Lectura Inicial

1. `docs/.generated/context-index.md` si existe.
2. `docs/WORKING_MEMORY.md`.
3. `docs/TOPICS.md` o busqueda por triggers.
4. Topic, track, spec o codigo puntual segun el pedido.
5. `docs/README.md` solo si hace falta mapa documental.

No abrir docs largos ni crear estructura de producto hasta que el objetivo del workspace este definido.

## Reglas

- Responder en espanol por defecto.
- No inventar stack, comandos, deploy, datos ni decisiones: usar placeholders honestos hasta que el proyecto tenga contenido real.
- No commitear secretos, `.env`, bases locales, exports privados ni datos sensibles.
- No revertir cambios de usuario sin pedido explicito.
- La memoria durable vive en `docs/`; no usar chats como fuente de verdad.
- Si aparecen archivos preexistentes de contexto, integrarlos, indexarlos, archivarlos o preguntar antes de borrarlos.
- Limitar `init/adopt/update/perfect os` a la capa agentica salvo pedido explicito.
- Para implementacion/review, `docs/topics/minimal-implementation.md` es politica liviana opcional: reusar lo existente y evitar dependencias/boilerplate innecesarios; Ponytail no es obligatorio ni dependencia local.

## Web, Internet E Instalaciones

- Usar web/internet libremente por defecto cuando conocimiento externo o cambiante evite adivinar: docs oficiales, releases, issues/source, metadata de paquetes, errores, APIs y comparativas. No enviar secretos, `.env`, codigo privado sensible, datos personales ni credenciales a servicios externos.
- Si evidencia online contradice el repo local, docs del proyecto o comportamiento observado, consultar a JP antes de decidir; presentar ambas evidencias, fuentes e impacto practico.
- Antes de instalar dependencias, CLIs globales, paquetes de sistema, herramientas de package-manager o binarios/scripts remotos, pedir autorizacion explicita con comando exacto, alcance, motivo, riesgos, alternativa, cambios esperados y rollback. Tratar `curl | sh`/scripts remotos como alto riesgo y preferir alternativas auditables.

## Comandos AOS

- `os help`: mostrar comandos OS disponibles y cuando usarlos.
- `sigamos`: continuar en este hilo sin guardado obligatorio.
- `gol` / `gol-lite`: ejecutar un lote chico verificable; no activa `/until-done` salvo pedido explicito.
- `guardar sesion`: persistir valor durable en docs vivos sin handoff ni thread nuevo. `aos-checkpoint` y `aos-cerrar-sesion` son aliases.
- `nueva sesion`: guardar y preparar handoff compacto para thread nuevo. `aos-continuar-sesion` es alias legado.
- `nueva sesion con gol`: nueva sesion que arranca con `gol`.
- `realinear os` / `aos-realinear-os`, `perfect os`, `init/adopt/update os`: usar `docs/topics/agentic-os-operations.md` y `docs/topics/os-quality.md`.
- Skills/prompts canonicos usan prefijo `aos-*`; los nombres sin prefijo quedan como compatibilidad legacy cuando existan.

## Comandos De Contexto

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
```
