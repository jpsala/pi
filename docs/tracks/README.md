---
status: reference
started: 2026-06-07
updated: 2026-06-07
priority: medium
---

# Tracks

Trabajos retomables. Usar cuando una conversacion, investigacion o implementacion todavia no merece una decision estable, pero debe poder retomarse.

Cada archivo representa una mesa de trabajo, no una sesion historica. Se puede editar, compactar, limpiar, archivar o borrar cuando deje de servir.

## Frontmatter Obligatorio

```yaml
---
status: active
started: YYYY-MM-DD
updated: YYYY-MM-DD
priority: medium
---
```

Campos:

- `status`: `pending`, `active`, `paused`, `blocked`, `done` o `archived`.
- `started`: fecha en que se creo la track.
- `updated`: ultima fecha en que se actualizo.
- `priority`: `low`, `medium`, `high` o `critical`.
- `owner`: opcional; humano, agente o equipo responsable.
- `related`: opcional; docs, topics, specs o archivos relacionados.
- `topic`: opcional; topic principal que explica el contexto estable.
- `source_refs`: opcional; archivos de codigo o docs que deben revisarse para refrescar la track.

Usar `docs/tracks/TEMPLATE.md` como base para crear una track nueva.

## Listar Activos

```powershell
rg -l "status:\s*active" docs/tracks -g "*.md" -g "!archive/**"
```

## Archivo

Una track con `status: archived` debe vivir en `docs/tracks/archive/`.

Una track que vive en `docs/tracks/archive/` debe tener `status: archived`.

## Regla

Cuando una track produzca conocimiento durable, promoverlo a `docs/topics/`, `docs/DECISIONS.md`, `docs/PROJECT.md`, `docs/DEVELOPMENT.md`, una spec o el documento estable que corresponda.

No usar esta carpeta como transcript.

## Guardar Y Nueva Sesion

Al guardar o abrir una sesion nueva, usar `tracks` como fuente principal de continuidad cuando hay trabajo vivo:

- actualizar estado, checklist y proximo corte;
- promover decisiones durables a `docs/DECISIONS.md`;
- promover research y patrones a `docs/topics/`;
- actualizar `docs/WORKING_MEMORY.md`;
- evitar historial largo o duplicacion.

`guardar sesion` termina con una sintesis compacta despues de persistir valor y sigue en la misma sesion.

`nueva sesion` hace `guardar sesion` y despues abre un thread nuevo con handoff compacto si la herramienta esta disponible. Si no lo esta, devolver un prompt pegable. El handoff debe apuntar a docs actualizados; no debe reemplazarlos ni repetirlos.

## Checklist De Nueva Sesion

Al abrir una sesion nueva:

1. Ejecutar `guardar sesion`.
2. Regenerar `docs/.generated/context-index.md`.
3. Correr `bun scripts/agent-context-audit.ts`.
4. Crear un thread nuevo si la herramienta esta disponible; si no, devolver un prompt compacto con ruta del repo, track, topic, estado actual, riesgos, no-hacer y proximo paso.

## Refrescar Contra Codigo / Docs

Para revisar si una track sigue conectado con sus referencias declaradas:

```powershell
bun scripts/context-refresh.ts --track docs/tracks/<track>.md
```

El script no edita archivos. Reporta `topic`, `related` y `source_refs` faltantes para que JP o el agente decidan que actualizar.