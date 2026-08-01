# OS Playbook

Guía corta para este workspace de customizaciones Pi.

| Necesidad | Usar |
| --- | --- |
| Pensar, planear con `execution_route`, abrir el handoff de ejecución o cerrar | `/flow` global |
| Sesión limpia manual fuera del handoff de Hacer | `/new` |
| Auditar/alinear AOS | ejecutar la operación manager desde `C:/dev/os` |
| Windows Input | `/windows-input status`, `/windows-input on/off/toggle` |
| Footer/statusline/UX | topic y restaurador local correspondiente |

`balanced` con Sol Medium es la ruta normal aun para trabajo multifile,
cross-layer o nativo acotado. `strong` con Sol High queda sólo para ambigüedad
material o fallos materiales difíciles de detectar; prioridad, cantidad de
archivos o un efecto externo autorizado no bastan. `economical` con Luna requiere
pedido explícito de JP por cuota y checks deterministas. `Ctrl+P` alterna Sol
Medium/High y `Ctrl+L` conserva la selección manual. Hacer aplica la ruta en la
sesión nueva y bloquea sin fallback si falta modelo o auth.

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
