# OS Playbook

Guia corta para operar este workspace con Agentic OS.

| Necesidad | Usar |
| --- | --- |
| Seguir en la sesion actual | `sigamos` |
| Proximo lote chico verificable | `gol` / `gol-lite` |
| Guardar valor durable | `guardar sesion` |
| Pasar a sesion limpia | `nueva sesion` |
| Auditar/reparar OS | `realinear os` |
| Dejar OS excelente | `perfect os` |
| Actualizar desde kit canonico | `update os` |
| Ver/controlar input estilo Windows en Pi | `/windows-input status`, `/windows-input on/off/toggle` |

## Sync Manual

```powershell
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

## Pi Windows Input

Extensión global documentada en `docs/topics/windows-input-extension.md`:

```text
/reload
/windows-input status
/windows-input on
/windows-input off
/windows-input toggle
```

Usar `/reload` en sesiones ya abiertas después de instalar o editar `C:\Users\jpsal\.pi\agent\extensions\windows-input.ts`.
