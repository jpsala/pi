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

## Sync Manual

```powershell
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

Si se habilita Pi adapter en el futuro, documentar aca los comandos slash disponibles.
