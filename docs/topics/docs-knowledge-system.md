---
id: docs-knowledge-system
status: active
kind: how-to
triggers:
  - documentacion
  - docs
  - topics
  - indice
  - working memory
primary_refs:
  - docs/.generated/context-index.md
  - docs/WORKING_MEMORY.md
  - docs/TOPICS.md
  - docs/tracks/
---

# Sistema De Conocimiento

## Ruta Caliente

1. `docs/.generated/context-index.md`.
2. `docs/WORKING_MEMORY.md`.
3. `docs/TOPICS.md`.
4. Topic, track o spec puntual.

## Reglas

- `WORKING_MEMORY.md` guarda estado vivo corto, no transcript.
- `TOPICS.md` enruta; los topics explican procedimientos o runbooks.
- `DECISIONS.md` guarda decisiones durables.
- `OPEN_QUESTIONS.md` guarda incertidumbres reales.
- `docs/tracks/` guarda trabajos vivos retomables.

Regenerar indice despues de cambios relevantes:

```powershell
bun scripts/context-index.ts
```
