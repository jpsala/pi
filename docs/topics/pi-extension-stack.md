---
id: pi-extension-stack
status: active
kind: reference
triggers:
  - extensiones pi
  - paquetes pi
  - pi packages
  - sincronizar pi
  - windows-input
  - pi footer
  - pi statusline
  - tool display
  - webui
  - /flow
  - notebook
  - note
  - ASUS
  - ssh notebook
primary_refs:
  - pi-extensions/README.md
  - docs/topics/windows-input-extension.md
  - docs/topics/pi-statusline-customization.md
  - docs/topics/pi-tool-renderer.md
  - C:/dev/os/docs/topics/pi-extension-stack.md
  - C:/dev/os/docs/topics/agent-tool-routing.md
  - C:/dev/infra/docs/runbooks/notebook-operations.md
  - aos.requirements.json
---

# Pi Extension Stack Local

`C:/dev/pi` es el laboratorio durable, portable y reversible de las customizaciones Pi que JP prueba o mantiene. Conserva fuentes, patches, configs saneadas, scripts y evidencia operativa para instalar, activar, desactivar, comparar, restaurar o retirar alternativas.

El runtime `/flow`, routing e inventario global general viven en `C:/dev/os`; este repo sí registra el estado y la historia de las piezas Pi experimentadas localmente.

## Fuentes

| Necesidad | Abrir |
| --- | --- |
| Usar `/flow`, Agent, advisor, web o lens | `C:/dev/os/docs/topics/pi-agentic-os.md` |
| Política de routing global | `C:/dev/os/docs/topics/agent-tool-routing.md` |
| Operar o sincronizar Pi en la notebook | `C:/dev/infra/docs/runbooks/notebook-operations.md` |
| Instalar/restaurar piezas propias | `pi-extensions/README.md` |
| Windows-like input | `docs/topics/windows-input-extension.md` |
| Footer/statusline | `docs/topics/pi-statusline-customization.md` |
| Renderer/estilos de tools | `docs/topics/pi-tool-renderer.md` |

## Piezas Propias

- `pi-extensions/windows-input.ts` y sus instaladores.
- `pi-extensions/codex-quota.ts` y snapshots portables de keybindings, theme y `pi-sticky-input`.
- snapshots, patches y restauradores de footer/statusline/usage.
- modo ultra compacto: reasoning oculto, `pi-code-previews` para built-ins sin previews y `pi-tool-display@0.5.0` sólo para `ffgrep`/`fffind`; `pi-claude-code-ui` desactivado.
- snapshots/restauradores de code previews, tool display y UX compacta.
- tracks/topics con extensiones evaluadas, versiones, estado, comportamiento de APIs, backups, smokes y rollback.

No copiarlas a `.pi/extensions/` si ya están globales: Pi puede cargar duplicados
y crear comandos sufijados.

## Contrato De Experimento Reversible

Para cada prueba o personalizacion relevante, registrar como mínimo:

- paquete y version, o fuente propia exacta;
- estado: `trial`, `active`, `disabled` o `removed`;
- archivos/settings globales y snapshots del repo afectados;
- comandos o scripts para instalar, aplicar y hacer toggle;
- backup previo y rollback probado o explícito;
- smoke/diagnostico realizado y riesgos conocidos;
- endpoint, frecuencia, cache y forma de datos cuando intervenga una API, sin persistir credenciales ni respuestas privadas.

No es obligatorio copiar todo el inventario global: sólo lo necesario para reproducir y revertir las piezas trabajadas desde este workspace.

## Reglas

1. `aos.requirements.json` declara el único `/flow` global requerido.
2. No mantener prompts de lifecycle, runtime `/flow`, routing state ni skills AOS
   manager-only en este repo.
3. Antes de instalar/remover paquetes o aplicar settings globales, pedir permiso
   y respaldar `C:/Users/jpsal/.pi/agent/settings.json`.
4. Ejecutar primero el modo status del restaurador cuando exista.
5. Después de aplicar una customización, `/reload` y smoke sólo de esa capacidad.
6. No tocar cuentas, producción, deploy ni datos privados sin autorización.

## Verificación

`get_commands` debe devolver exactamente un `flow`, scope `user`, origin
`package`, source `C:/dev/os/runtime/aos-flujo.ts`. Para la capa local:

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

Promover criterios globales a `C:/dev/os`; conservar aquí sólo conocimiento de
Windows Input, footer/statusline y UX propias.
