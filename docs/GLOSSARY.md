# Glosario

| Termino | Significado |
| --- | --- |
| AOS | Agentic OS: capa liviana de reglas, memoria, topics, skills, indice y audit. |
| Working Memory | `docs/WORKING_MEMORY.md`, estado vivo corto del proyecto. |
| Topic | Documento recuperable en `docs/topics/` con frontmatter y triggers. |
| Track | Trabajo vivo retomable en `docs/tracks/`. |
| Context Index | `docs/.generated/context-index.md`, cache generado para lectura rapida. |
| Skills Canonicas | `docs/skills/`, fuente de verdad de skills locales. |
| Skills Compat | `.agents/skills`, junction opcional hacia `docs/skills/`. |
| Init OS | Crear AOS minimo en una carpeta sin sistema agentico. |
| Adopt OS | Fusionar AOS en un repo con memoria/reglas previas. |
| Update OS | Actualizar una instalacion AOS existente sin pisar contexto local. |
| Perfect OS | Auditar y optimizar recuperabilidad, liviandad y continuidad. |
| `/flow` | Entrada Pi global: Pensar, Planear con `execution_route`, Hacer o Cerrar. |
| Handoff documental de Hacer | Sesión nueva enlazada que carga índice, Working Memory y brief para revisión antes de ejecutar directamente. |
| Cerrar | Persistir valor durable todavía faltante; es opcional si Hacer ya cerró y `/new` queda para sesiones manuales. |
| Windows Input | Extensión global `windows-input.ts` que reemplaza el prompt principal de Pi con selección/edición estilo Windows/VS Code. |
