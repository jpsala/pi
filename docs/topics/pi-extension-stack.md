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
  - hide messages
  - webui
  - pi-dynamic-workflows
primary_refs:
  - pi-extensions/README.md
  - docs/topics/windows-input-extension.md
  - docs/topics/pi-statusline-customization.md
  - C:/dev/os/docs/topics/pi-extension-stack.md
  - C:/dev/os/docs/topics/agent-tool-routing.md
  - C:/dev/os/docs/reference/tool-routing.yaml
---

# Pi Extension Stack Local

`C:/dev/pi` no es el inventario global de paquetes Pi. Este repo guarda solo
fuentes y snapshots propios de JP para restaurar o portar configuraciones Pi.
El flow de herramientas, routing y lista global versionada viven en `C:/dev/os`.

## Fuentes Canonicas

| Necesidad | Abrir |
| --- | --- |
| Elegir herramientas Pi, paquetes globales, `advisor`, taskflow, web, lens | `C:/dev/os/docs/topics/pi-extension-stack.md` |
| Routing de motores, `pi_long_task`, `dgoal`, `pi-dynamic-workflows` | `C:/dev/os/docs/topics/agent-tool-routing.md` |
| Instalar/restaurar piezas propias de JP desde este repo | `pi-extensions/README.md` |
| Windows-like input editor | `docs/topics/windows-input-extension.md` |
| Footer/statusline compacto | `docs/topics/pi-statusline-customization.md` |

## Piezas Propias De Este Repo

- `pi-extensions/windows-input.ts`: fuente portable de la extension global
  `windows-input`; instalar con `scripts/install-windows-input.ps1` o `.sh`.
- `pi-extensions/pi-footer.json`: snapshot de footer/statusline compacto.
- `scripts/apply-pi-statusline-customization.ps1` / `.sh`: restauran footer y
  parches locales de statusline/codex usage.
- `pi-extensions/pi-tool-display.json` y `pi-extensions/pi-hide-messages.json`:
  UX compacta de tools/WebUI.
- `scripts/apply-pi-webui-ux.ps1` / `.sh`: restauran configs de UX compacta y
  parche WebUI cuando JP lo pide.

No copiar estas piezas a `.pi/extensions/` por defecto si ya existe una copia
global: Pi puede cargar duplicados y crear comandos sufijados.

## Regla Operativa

1. Para decidir o comparar herramientas, usar `C:/dev/os` como fuente.
2. Para instalar/remover paquetes globales o CLIs, pedir permiso explicito y
   respaldar `C:/Users/jpsal/.pi/agent/settings.json`.
3. Para restaurar una pieza local, ejecutar primero el modo status del script si
   existe; aplicar solo la pieza pedida.
4. Despues de cambios Pi, correr `/reload` y smoke-testear solo la capacidad
   tocada. No tocar cuentas reales, prod, deploy ni datos privados sin permiso.

## Pi Dynamic Workflows

Este repo no convierte `pi-dynamic-workflows` en default. Si se usa, seguir el
playbook upstream y mantenerlo opt-in:

```json
{
  "keywordTriggerEnabled": false,
  "keywordTriggerWord": "pi-workflow"
}
```

Si aparece `[workflows mode is ON]` en mensajes normales, revisar
`C:/Users/jpsal/.pi/workflows/settings.json` como JSON UTF-8 sin BOM, correr
`/reload` y verificar `/workflows-trigger status`. `taskflow` sigue siendo el
default AOS para fan-out salvo piloto explicito.

## Sincronizar Otra PC

1. Abrir `pi-extensions/README.md` y el topic puntual (`windows-input` o
   `pi-statusline-customization`).
2. Ejecutar status del script correspondiente.
3. Aplicar solo la configuracion solicitada.
4. Ejecutar `/reload` en Pi y verificar el comando/capacidad tocada.
5. Si hace falta elegir paquetes o revisar inventario global, volver a
   `C:/dev/os`; no duplicar ese inventario aca.

## Mantenimiento

Guardar aca solo aprendizajes sobre extensiones/configs propias de JP. Promover
criterios globales de uso de herramientas a `C:/dev/os` para evitar drift entre
repos AOS.
