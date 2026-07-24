---
id: agent-tool-routing
status: active
kind: policy
triggers:
  - tool routing
  - routing decision
  - /flow
  - elegir herramienta
  - subagente
primary_refs:
  - docs/reference/tool-routing.yaml
  - docs/topics/pi-agentic-os.md
  - C:/dev/os/docs/topics/agent-tool-routing.md
  - aos.requirements.json
---

# Agent Tool Routing

Este workspace sigue la política global **flow-first**: una entrada, un batch y
el menor mecanismo suficiente.

| Intención | Ruta |
| --- | --- |
| Entender o decidir | `/flow → Pensar` |
| Crear brief durable | `/flow → Planear` |
| Implementar | `/flow → Hacer`: sesión nueva enlazada, handoff documental y ejecución directa sin Agent |
| Persistir lo todavía faltante | `/flow → Cerrar` |

Planear declara una ruta revisable en el brief: `economical` usa Luna High para
docs o mecánica de bajo riesgo, `balanced` usa Sol Medium por defecto y `strong`
usa Sol High para trabajo sensible. Hacer la aplica en la sesión nueva; modelo o
auth ausentes bloquean sin fallback. No hay Terra, clasificador extra ni routing
por turno.

Hacer lee sólo el foco estricto de `WORKING_MEMORY`: 0 deriva, 1 autoselecciona y
N abre picker. Un foco o path inválido bloquea antes de abrir la sesión; el
handoff queda revisable y nunca se autoenvía.

## Apoyos

- CodeMapper/FFF para orientación.
- LSP/Lens para diagnóstico.
- Advisor para riesgo o conflicto.
- Web/librarian para conocimiento externo.
- Ask User para decisiones humanas.
- Chrome/CUA para UI explícita con aviso.

No hay registro de engine ni runtime state local. Taskflow, Council, planner,
until-done, dgoal, Ponytail, Governed Runner y worktree bridge están retirados;
no recrearlos como fallback.

Preguntar antes de installs, credenciales, acciones destructivas o externas,
commit, push, deploy o producción. La policy verificable está en
`docs/reference/tool-routing.yaml`; la autoridad global vive en `C:/dev/os`.
