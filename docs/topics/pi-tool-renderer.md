---
id: pi-tool-renderer
status: active
kind: how-to
triggers:
  - renderer Pi
  - estilos tools
  - estilo Pi
  - pi-code-previews
  - pi-claude-code-ui
  - tool previews
  - Ctrl+O
primary_refs:
  - ../tracks/pi-ui-usage-evaluation.md
  - ../../pi-extensions/README.md
  - C:/Users/jpsal/.pi/agent/settings.json
---

# Pi Tool Renderer

Estado e historia de las extensiones probadas por JP para cambiar la presentacion de tools en la TUI de Pi.

## Respuesta Corta

| Rol | Extensión | Estado actual |
| --- | --- | --- |
| Built-ins | `pi-code-previews@0.1.36` | una línea, sin fondo ni previews colapsadas |
| Tools custom | `pi-tool-display@0.5.0` | sólo `ffgrep`/`fffind` en `summary` |
| Renderer anterior | `pi-claude-code-ui@1.0.74` | instalado pero desactivado con `extensions: []` |

No confundir estos renderers con:

- el theme global `jp-tokyo-night-user-focus`;
- `pi-footer`, que controla footer/statusline;
- `pi-tool-display`, que controla visibilidad/resumen de output.

## Reparto Efectivo Ultra Compacto

El modo adoptado el 2026-07-25 evita ownership solapado:

- `pi-code-previews` posee las siete built-ins, sin fondo ni previews colapsadas;
- `pi-tool-display` no posee built-ins y sólo resume tools custom explícitas;
- en `settings.json`, `pi-tool-display` precede a `pi-fff` para interceptar su registro;
- `hideThinkingBlock: true` oculta los bloques de razonamiento `Verifying…`/`Updating…`.

`pi-tool-display@0.5.0` se instaló globalmente para reducir bloques extensos como los resultados de `ffgrep`:

```json
"customToolOverrides": {
  "ffgrep": { "enabled": true, "kind": "generic", "outputMode": "summary" },
  "fffind": { "enabled": true, "kind": "generic", "outputMode": "summary" }
}
```

En modo `summary`, la vista colapsada muestra sólo cantidad de líneas y conserva el resultado completo con `Ctrl+O`. Snapshot saneado: `pi-extensions/pi-tool-display.json`; config viva: `~/.pi/agent/extensions/pi-tool-display/config.json`.

Evidencia:

- `pi list` resolvió `npm:pi-tool-display@0.5.0`;
- RPC registró `/tool-display` desde scope global `user/package`;
- el loader resolvió ownership built-in completamente apagado;
- `ffgrep` y `fffind` resolvieron como `generic/summary`;
- RPC fresco cargó ambos renderers sin `extension_error`;
- backup inicial: `~/.pi/agent/backups/pi-tool-display-adoption-20260725-110418/`;
- backup del modo ultra compacto: `~/.pi/agent/backups/pi-ultra-compact-20260725-111740/`;
- backup previo al ajuste de orden: `~/.pi/agent/backups/pi-tool-display-load-order-20260725-114830/`.

Riesgos: intercepta el registro y render de tools; no activar ownership visual solapado en otros renderers. El output enviado al modelo no cambia, sólo la presentación colapsada. Tras cambios, ejecutar `/reload` y probar `ffgrep`, `fffind`, `read`, `edit` y `Ctrl+O`.

Rollback:

```powershell
pi remove npm:pi-tool-display
Copy-Item "$env:USERPROFILE\.pi\agent\backups\pi-tool-display-adoption-20260725-110418\settings.json" "$env:USERPROFILE\.pi\agent\settings.json" -Force
Remove-Item "$env:USERPROFILE\.pi\agent\extensions\pi-tool-display\config.json" -Force
```

Luego `/reload`. El install reportó dos advisories npm del árbol global (1 moderate, 1 high), pero `npm audit` no pudo consultar el endpoint por un fallo TLS; no se ejecutó `npm audit fix` ni se alteraron dependencias adicionales.

Fuentes:

- custom override y decoración de tools registradas: <https://github.com/MasuRii/pi-tool-display/blob/91cef7580078371f8dc49a8607222807ad6a424d/src/tool-overrides.ts#L1918-L2061>;
- modos `hidden`/`summary`/`preview` y expansión completa: <https://github.com/MasuRii/pi-tool-display/blob/91cef7580078371f8dc49a8607222807ad6a424d/src/tool-overrides.ts#L1198-L1237>.

## Built-ins: `pi-code-previews`

`pi-code-previews` posee `bash`, `read`, `write`, `edit`, `grep`, `find` y `ls`. Su snapshot `pi-extensions/pi-code-previews.json` fija:

- previews de contenido, resultados y diffs en `false`;
- `toolCallBackground: off` y timing/syntax apagados;
- detalle completo disponible con `Ctrl+O`.

Estado validado:

- paquete fijado: `pi-code-previews@0.1.36`;
- `/code-preview-health` está registrado por RPC sin errores;
- `/code-preview-settings` abre su configuración.

## Parche Histórico Retirado

El patch `pi-code-previews-0.1.36-tools-authoritative.patch` resolvía un caso
anterior: persistir `tools: []` sin que otros toggles reactivaran renderers. El
modo actual habilita las siete built-ins, por lo que ese cambio ya no aporta
valor.

El 2026-07-25 se restauraron desde los backups originales los cinco archivos
modificados (`values.ts`, `selection.ts`, dos archivos UI y `dist/index.js`). La
comparación byte a byte pasó y un RPC aislado cargó `/code-preview-health` sin
errores. El paquete instalado vuelve a ser el upstream limpio `0.1.36`.

Configuración actual:

```json
{
  "tools": ["bash", "read", "write", "edit", "grep", "find", "ls"],
  "toolCallBackground": "off",
  "editDiffPreview": false
}
```

El patch queda versionado sólo como antecedente; no reaplicarlo mientras este
modo siga usando todas las built-ins. Backup inmediato anterior a la limpieza:

```text
~/.pi/agent/backups/pi-code-previews-clean-restore-20260725-113303/
```

## Renderer Anterior: `pi-claude-code-ui`

`pi-claude-code-ui@1.0.74` agrupa tool rows con estilo Claude Code y registra dos extensiones (`extensions/index.ts` y `extensions/spinner.ts`). Sigue instalada para permitir comparacion/retorno rapido, pero Pi no carga sus extensiones porque `settings.json` contiene:

```json
{
  "source": "npm:pi-claude-code-ui",
  "extensions": []
}
```

No dar ownership de una misma tool a ambos renderers: pueden coexistir sólo con responsabilidades disjuntas.

## Toggle Reversible

Antes de cambiar:

1. respaldar `~/.pi/agent/settings.json`;
2. usar `pi config` o editar solamente las dos entradas de paquetes;
3. ejecutar `/reload`;
4. hacer smoke con `read`, `edit`, `bash` y `Ctrl+O`.

Estado actual:

```json
"npm:pi-tool-display@0.5.0"
```

```json
{
  "source": "npm:pi-claude-code-ui",
  "extensions": []
}
```

```json
"npm:pi-code-previews@0.1.36"
```

Para volver temporalmente al renderer anterior, habilitar `pi-claude-code-ui` y deshabilitar sólo los recursos de `pi-code-previews`:

```json
"npm:pi-claude-code-ui"
```

```json
{
  "source": "npm:pi-code-previews@0.1.36",
  "extensions": []
}
```

No hace falta desinstalar para alternar. Remover un paquete requiere autorización explícita.

## Backup Y Rollback

Backup historico previo a la prueba:

```text
~/.pi/agent/backups/code-previews-trial-20260722-100300/
```

Ese `settings.json` es una referencia del estado anterior, no debe restaurarse completo ahora porque fue creado antes de cambios globales posteriores como `pi-openai-usage`. Para rollback, modificar sólo las entradas de estos dos renderers y luego `/reload`.

Si `pi-code-previews` falla:

1. deshabilitar sus recursos;
2. habilitar `pi-claude-code-ui` o dejar ambos deshabilitados;
3. `/reload`;
4. verificar que exista un solo dueño visual por tool.
