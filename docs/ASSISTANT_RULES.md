# Reglas Para Agentes

- Seguir `AGENTS.md` como ruta caliente.
- Leer poco: indice, working memory, topics, luego foco puntual.
- Mantener docs cortos y recuperables.
- Preguntar antes de borrar memoria dudosa, tocar datos, deploy o configuraciones externas.
- Si falta contexto, registrar placeholders honestos y preguntas abiertas.

## Optional Pi / RTK

If this repo is used from Pi and `[rtk] No hook installed` appears, treat it as a global token-savings notice, not a repo problem. RTK is optional and must not be committed as repo config. Safe policy: keep exact reads unfiltered (`readCompaction.enabled=false`, `sourceCodeFilteringEnabled=false`), use RTK only for noisy shell output, and use raw output or direct file reads for final evidence, edit anchors, exact line numbers, and rare errors.
