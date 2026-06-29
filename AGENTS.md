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

## Comandos AOS

- `os help`: mostrar comandos OS disponibles y cuando usarlos.
- `sigamos`: continuar en este hilo sin guardado obligatorio.
- `gol` / `gol-lite`: ejecutar un lote chico verificable; no activa `/until-done` salvo pedido explicito.
- `guardar sesion`: persistir valor durable en docs vivos sin handoff ni thread nuevo. `checkpoint` y `cerrar sesion` son aliases.
- `nueva sesion`: guardar y preparar handoff compacto para thread nuevo. `continuar sesion` es alias legado.
- `nueva sesion con gol`: nueva sesion que arranca con `gol`.
- `realinear os` / `aos-realinear-os`, `perfect os`, `init/adopt/update os`: usar `docs/topics/agentic-os-operations.md` y `docs/topics/os-quality.md`.

## Comandos De Contexto

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
```
