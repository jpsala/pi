# OS Playbook

Guía corta para este workspace de customizaciones Pi.

| Necesidad | Usar |
| --- | --- |
| Pensar, planear con `execution_route`, abrir el handoff de ejecución o cerrar | `/flow` global |
| Sesión limpia manual fuera del handoff de Hacer | `/new` |
| Auditar/alinear AOS | ejecutar la operación manager desde `C:/dev/os` |
| Windows Input | `/windows-input status`, `/windows-input on/off/toggle` |
| Footer/statusline/UX | topic y restaurador local correspondiente |

Planear declara `economical` (Luna High), `balanced` (Sol Medium, default) o
`strong` (Sol High). Hacer aplica esa ruta en la sesión nueva y bloquea sin
fallback si falta modelo o auth.

## Contexto Local

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
```

## Windows Input

La fuente portable está en `pi-extensions/windows-input.ts`. Después de una
aplicación autorizada, usar `/reload` y verificar sólo la capacidad tocada. No
copiar runtime AOS, prompts de lifecycle ni inventario global a este repo.
