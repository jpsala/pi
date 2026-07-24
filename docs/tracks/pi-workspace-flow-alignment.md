---
status: complete
started: 2026-07-19
updated: 2026-07-20
priority: high
owner: JP + Pi
topic: docs/topics/pi-agentic-os.md
related:
  - docs/WORKING_MEMORY.md
  - docs/topics/pi-extension-stack.md
  - docs/topics/windows-input-extension.md
  - docs/topics/pi-statusline-customization.md
  - C:/dev/os/docs/tracks/aos-flow-contract-polish.md
source_refs:
  - AGENTS.md
  - .pi/prompts/aos-gol.md
  - scripts/agent-context-audit.ts
  - pi-extensions/README.md
  - pi-extensions/windows-input.ts
---

# Pi Workspace Flow Alignment

## Objetivo

Definir y alinear `C:/dev/pi` como repositorio de customizaciones Pi portables
de JP —Windows Input, footer/statusline y UX— que consume `/flow` únicamente
desde `C:/dev/os`, sin duplicar runtime, comandos ni gobierno AOS.

## No Objetivos

- Implementar o modificar `/flow` antes de estabilizar su contrato upstream.
- Copiar tracks, memoria, registry o decisiones manager-only desde `C:/dev/os`.
- Instalar/remover paquetes ni aplicar configuraciones al Pi global.
- Ejecutar instaladores/restauradores de Windows Input, footer o WebUI.
- Resolver o sobrescribir el WIP actual de statusline.
- Limpiar `.pi/taskflows/`, `tmp/`, `NUL` u otros artefactos no clasificados.
- Hacer commit, push, deploy, producción o efectos externos.

## Baseline A Preservar

- `pi-extensions/windows-input.ts` y sus instaladores portables.
- Snapshots/restauradores de footer, statusline y UX compacta.
- Cambios tracked actuales en docs/config/scripts de statusline.
- Untracked `.pi/taskflows/`, `tmp/` y `NUL` hasta conocer ownership.
- Branch `main` alineada con `origin/main` al crear este plan.
- `C:/dev/os` sigue siendo la única autoridad de runtime, routing y `/flow`.

No hacer stash, reset, restore, stage, borrado ni reemplazo masivo del baseline.

## Hallazgos Iniciales

- `AGENTS.md`, `docs/OS_PLAYBOOK.md`, `docs/topics/pi-agentic-os.md` y routing
  todavía presentan `sigamos`, `gol`, `/aos-*`, perfiles y motores retirados.
- `.pi/prompts/aos-gol.md` conserva una superficie AOS local legacy.
- `scripts/agent-context-audit.ts` exige prompts/extensiones/comandos AOS que ya
  no forman parte del runtime flow-first.
- El índice generado reproduce esos triggers obsoletos.
- La Working Memory ya declara correctamente que inventario y flow global viven
  en `C:/dev/os`, pero el resto de la capa documental no converge con eso.
- El propósito raíz sigue “pendiente” aunque el uso real ya está descrito:
  customizaciones Pi propias, portables y restaurables.

Baseline de planificación: el índice se regeneró y `git diff --check` pasó. El
context audit actual falla con 15 errores coherentes con el drift inventariado:
exige seis prompts, dos extensiones y siete comandos `/aos-*` retirados del
upstream. No restaurarlos para poner el audit verde; Batch 3 debe corregir sus
supuestos después de estabilizar el contrato upstream.

## Dependencia Resuelta

`C:/dev/os/docs/tracks/aos-flow-contract-polish.md` y el smoke global Batch 2I
cerraron el contrato upstream el 2026-07-20. La alineación downstream quedó
habilitada y se ejecutó con backup externo.

## Batches Verificables

### Batch 1 — Inventario Y Ownership (completado 2026-07-19)

- Capturar status y clasificar cada cambio tracked/untracked actual.
- Inventariar docs, skills, prompts y checks AOS locales como vigente, portable,
  stale, histórico o artefacto runtime.
- Confirmar el propósito del repo y ownership de Windows Input/statusline/UX.
- Identificar solapamientos exactos con upstream sin editar runtime ni docs
  legacy todavía.
- Registrar evidencia compacta en este track.

**Done:** baseline y ownership verificables, ninguna procedencia ambigua y cero
ediciones fuera de track/Working Memory/índice.

#### Receipt

**Baseline Git.** `main` estaba alineada con `origin/main` (`+0/-0`) y no había
staging. Se preservaron siete cambios tracked preexistentes:

- `docs/.generated/context-index.md` y `docs/WORKING_MEMORY.md`: WIP
  documental de planificación local, vigente y preservado.
- `docs/reference/tool-routing.yaml`: WIP AOS/routing downstream que solapa
  gobierno de `C:/dev/os`; preservar hasta la receta de Batch 2.
- Topic, snapshot y dos restauradores de statusline: WIP portable propiedad de
  `C:/dev/pi`, fuera de la alineación AOS.

También se preservaron ocho entradas untracked:

- `docs/tracks/pi-workspace-flow-alignment.md`: track durable vigente.
- Los dos archivos de `.pi/taskflows/runs/`: artefactos runtime de una ejecución
  Taskflow completada; no son source.
- Los dos archivos de `tmp/pi-long-task/`: salida histórica/runtime de
  `pi-long-task`; no es source.
- `tmp/aos-routing-v2-integration-plan.md` y
  `tmp/plannotator-submit-status.md`: artefactos históricos Plannotator cuyo
  target declarado es `C:/dev/os`; no tienen autoridad en este repo.
- `NUL`: artefacto runtime local con nombre reservado de Windows. Git lo
  reporta como untracked; no tiene consumidor/source identificado y se preserva
  sin abrirlo ni limpiarlo.

La procedencia relevante queda resuelta a nivel de ownership: los residuos de
runtime no son fuente portable ni gobierno AOS; no se infiere qué proceso creó
`NUL`, porque no cambia su disposición segura de preservarlo.

**Inventario y ownership.** El propósito operativo verificable de `C:/dev/pi`
es mantener customizaciones Pi propias, portables y restaurables. La identidad
`pending` de `docs/PROJECT.md` queda clasificada como stale para alinear en Batch
3; no habilita producto/runtime/deploy.

- Windows Input, sus instaladores y topic: **portable, vigente**; fuente propia
  de `C:/dev/pi`.
- Footer/statusline y UX: **portable, vigente con WIP preservado**;
  fuentes/snapshots propios de `C:/dev/pi`.
- Topic de extension stack y `pi-extensions/README.md`: **vigente**; referencia
  inventario/flow externo sin duplicarlo.
- `AGENTS.md`, playbook, topics Pi/AOS y routing local: **stale como superficie
  operativa flow-first**; Batch 3 los alinea después del contrato upstream.
- Las 20 skills, su junction `.agents/skills` y el prompt `aos-gol`:
  **stale/legacy como comandos AOS locales**. Conservar hasta la receta sin
  asumir que son canon upstream.
- `scripts/context-index.ts`: **vigente**; generador local del índice.
- `scripts/agent-context-audit.ts`: **stale en expectativas Pi/AOS**; exige seis
  prompts, dos extensiones y siete comandos retirados.
- `docs/DECISIONS.md` y decisiones `/aos-*`: **histórico**; conservar como
  historia, no como command surface vigente.
- Runtime, routing, inventario global y `/flow`: **externo**; autoridad única en
  `C:/dev/os`, sin copia ni modificación desde este batch.

**Solapamientos exactos.** La comparación read-only contra rutas
correspondientes de `C:/dev/os` encontró cero archivos byte-idénticos entre
`AGENTS.md`, playbook, topic Pi/AOS, audit, prompt y las 20 skills locales. Los
archivos de igual ruta (`AGENTS.md`, playbook, topic, audit y README de skills)
existen upstream pero difieren; las skills upstream usan otra superficie
`aos-*`. El único duplicado exacto local es la junction `.agents/skills` →
`docs/skills`. Además, `docs/topics/pi-agentic-os.md` referencia
`docs/reference/pi-agentic-os-command-surface.md`, que no existe localmente:
evidencia adicional de drift, no permiso para restaurarlo.

**Evidencia de cierre.** El audit baseline devolvió exactamente los 15 errores
ya documentados (6 prompts + 2 extensiones + 7 comandos), sin warnings ni nueva
categoría. Los modos read-only descubiertos son `--status`/`-Status` para Windows
Input y statusline; WebUI no expone modo status. No se ejecutó ningún instalador
o restaurador.

### Batch 2 — Contrato De Proyección Upstream (completado 2026-07-20)

- Verificar que el track upstream de polish esté completo.
- Leer la superficie canónica final de `/flow`, routing y audits.
- Definir qué viaja a este repo y qué debe quedar sólo como referencia externa.
- Preparar una lista exacta de conservar, actualizar, archivar y eliminar.

**Done:** receta aprobada sin copiar gobierno manager-only ni inventar runtime.

### Batch 3 — Alineación AOS Local (completado 2026-07-20)

- Actualizar `AGENTS.md`, playbook, topics, glossary y referencias activas.
- Retirar o archivar skills/prompts AOS legacy sólo según la receta aprobada.
- Adaptar `scripts/agent-context-audit.ts` al contrato flow-first downstream.
- Mantener las customizaciones Pi portables fuera de la superficie AOS diaria.

**Done:** el repo no publica ni documenta comandos/perfiles/motores fantasma.

### Batch 4 — Verificación De Customizaciones (completado 2026-07-20)

- Verificar source y documentación de Windows Input, footer/statusline y UX.
- Confirmar que no existen duplicados locales/globales ni paths rotos.
- Usar modos status/read-only cuando existan.
- Cualquier aplicación global o smoke visible requiere autorización separada.

**Done:** assets portables coherentes y verificables sin alterar la instalación.

### Batch 5 — Cierre (completado 2026-07-20)

- Compactar track y Working Memory.
- Regenerar índice y ejecutar audit/checks finales.
- Registrar deuda separada para WIP de statusline o artefactos que no pertenezcan
  a la alineación AOS.
- Preparar resumen revisable sin commit ni push.

**Done:** `C:/dev/pi` tiene propósito claro, AOS sin drift y customizaciones
portables preservadas.

## Resultado Final

- `aos.requirements.json` exige un único `/flow` global `user/package` desde
  `C:/dev/os/runtime/aos-flujo.ts`; no existe copia local.
- Se retiraron el prompt `aos-gol` y las 20 skills AOS legacy, preservados en el
  backup externo; `docs/skills/` queda como canon vacío para futuras skills
  específicas de customizaciones Pi.
- AGENTS, playbook, topics, routing y audit usan la superficie flow-first y ya no
  publican comandos, motores o runtime state retirados.
- Windows Input, footer/statusline, tool display, UX y sus restauradores quedaron
  intactos. No se aplicaron configuraciones globales ni se instalaron paquetes.
- Backup y evidencia:
  `C:/Users/jpsal/.pi/agent/backups/aos-align-dict-pi-20260720-150313/`.

## Checks

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
git diff --check
git status --short
```

Batch 1 debe descubrir checks adicionales existentes sin instalar herramientas.
Los instaladores y restauradores sólo pueden ejecutarse en modo status/read-only
hasta una autorización explícita posterior.

## Riesgos

- Copiar un contrato upstream todavía cambiante.
- Borrar skills/prompts que aún tengan consumidor local no inventariado.
- Confundir artefactos runtime con source portable.
- Mezclar el WIP de statusline con la alineación AOS.
- Duplicar Windows Input o configuraciones ya cargadas globalmente.
- Hacer que el audit nuevo rechace historia legítima o tmp deliberado.

## Stop Conditions

Detenerse y pedir decisión explícita ante:

- upstream flow polish incompleto al intentar Batch 2;
- ownership incierto o cambios ajenos incompatibles;
- necesidad de tocar `C:/dev/os`, otra repo o configuración global;
- installs, `/reload`, UI visible, hotkeys, clipboard o aplicación de configs;
- secretos, auth, settings privados, cuentas o datos reales;
- stash/reset/restore/stage, limpieza de `NUL`, `tmp/` o `.pi/taskflows/`;
- commit, push, deploy, producción o cualquier efecto externo.
