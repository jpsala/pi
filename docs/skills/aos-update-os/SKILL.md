---
name: aos-update-os
description: Update an existing downstream AOS installation against this upstream kit, bringing only applicable local runtime pieces and never copying AOS manager-only context. Use when JP says `update os`, `actualiza el os`, or asks to update/improve/audit another AOS repo.
---

# Update OS

Actualizar un AOS existente contra este kit canonico.

Fuente canonica: `docs/topics/agentic-os-operations.md`, seccion `Update`.

Comparar por capas: docs/scripts locales, skills, Codex `.agents`, Pi `.pi`, Claude/otros adapters si existen, SpecKit si aplica, indice y audit. Fusionar sin pisar memoria local, omitir piezas manager-only de AOS (`OS_PROJECTS`, decisiones/tracks/memoria del kit, inventarios globales) y reportar capas aplicadas u omitidas.
