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

| Rol | Extension | Estado actual |
| --- | --- | --- |
| Renderer adoptado | `pi-code-previews@0.1.36` | instalada y activa |
| Renderer anterior | `pi-claude-code-ui@1.0.74` | instalada pero desactivada con `extensions: []` |

No confundir estos renderers con:

- el theme global `jp-tokyo-night-user-focus`;
- `pi-footer`, que controla footer/statusline;
- `pi-tool-display`, que controla visibilidad/resumen de output.

## Renderer Actual: `pi-code-previews`

Motivo de adopcion: mejora cada tool de forma granular sin imponer una UI agrupada completa. Decora `bash`, `read`, `write`, `edit`, `grep`, `find` y `ls`, y omite una preview si otra extension ya es dueña de ese tool.

Estado validado el 2026-07-22:

- paquete fijado: `pi-code-previews@0.1.36`;
- `/code-preview-health` paso por RPC y visualmente;
- `/code-preview-settings` abre su configuracion;
- `Ctrl+O` expande o contrae el output.

## Parche Activo: `tools` Autoritativo

`pi-code-previews@0.1.36` tenia una precedencia inesperada: al apagar todos los
items de `Enabled tools`, `values.ts` y `tools/selection.ts` volvían a agregar
los tools cuyo preview de contenido/resultados estaba en `false`. Por eso el
estado no sobrevivía a `/reload` y sólo `edit` quedaba apagado.

Se aplicó un parche local para que `tools` sea una allowlist explícita del
usuario. Los previews de contenido pueden seguir en `false`, pero nunca vuelven
a activar un tool apagado. Además, cada toggle se persiste inmediatamente; no
depende de cerrar correctamente el submenú. El parche versionado está en:

```text
pi-extensions/patches/pi-code-previews-0.1.36-tools-authoritative.patch
```

Backup de esta aplicación:

```text
C:/Users/jpsal/.pi/agent/backups/code-previews-tools-immediate-save-20260723-103734/
```

Backup del estado upstream previo a cualquier parche:

```text
C:/Users/jpsal/.pi/agent/backups/code-previews-tools-authoritative-20260722-131641/
```

Rollback exacto del parche completo en Windows:

```powershell
$backup = 'C:\Users\jpsal\.pi\agent\backups\code-previews-tools-immediate-save-20260723-103734'
$pkg = "$env:USERPROFILE\.pi\agent\npm\node_modules\pi-code-previews"
Copy-Item "$backup\code-previews.json" "$env:USERPROFILE\.pi\agent\code-previews.json" -Force
Copy-Item "$backup\package\src\settings\values.ts" "$pkg\src\settings\values.ts" -Force
Copy-Item "$backup\package\src\tools\selection.ts" "$pkg\src\tools\selection.ts" -Force
Copy-Item "$backup\package\src\settings\ui\index.ts" "$pkg\src\settings\ui\index.ts" -Force
Copy-Item "$backup\package\src\settings\ui\submenus.ts" "$pkg\src\settings\ui\submenus.ts" -Force
Copy-Item "$backup\package\dist\index.js" "$pkg\dist\index.js" -Force
```

El backup `code-previews-tools-authoritative-20260722-131641` revierte sólo
la primera versión del parche y deja fuera el guardado inmediato. Para volver
al upstream original hay que restaurar además sus archivos planos:

```powershell
$backup = 'C:\Users\jpsal\.pi\agent\backups\code-previews-tools-authoritative-20260722-131641'
$pkg = "$env:USERPROFILE\.pi\agent\npm\node_modules\pi-code-previews"
Copy-Item "$backup\code-previews.json" "$env:USERPROFILE\.pi\agent\code-previews.json" -Force
Copy-Item "$backup\package\values.ts" "$pkg\src\settings\values.ts" -Force
Copy-Item "$backup\package\selection.ts" "$pkg\src\tools\selection.ts" -Force
$uiBackup = 'C:\Users\jpsal\.pi\agent\backups\code-previews-tools-immediate-save-20260723-103734\package'
Copy-Item "$uiBackup\src\settings\ui\index.ts" "$pkg\src\settings\ui\index.ts" -Force
Copy-Item "$uiBackup\src\settings\ui\submenus.ts" "$pkg\src\settings\ui\submenus.ts" -Force
Copy-Item "$backup\package\index.js" "$pkg\dist\index.js" -Force
```

Configuración actual esperada:

```json
"tools": []
```

Tras actualizar `pi-code-previews`, revisar la versión antes de reaplicar. Si
sigue siendo `0.1.36`, respaldar primero y aplicar el patch desde la raíz de
este repo. La actualización incluye tanto la allowlist autoritativa como el
guardado inmediato de cada toggle:

```powershell
$patch = 'C:\dev\pi\pi-extensions\patches\pi-code-previews-0.1.36-tools-authoritative.patch'
$pkg = "$env:USERPROFILE\.pi\agent\npm\node_modules\pi-code-previews"
git apply --check --unsafe-paths --directory="$pkg" $patch
git apply --unsafe-paths --directory="$pkg" $patch
```

Verificar que `src/settings/values.ts`, `src/tools/selection.ts` y `dist/index.js`
contengan la variante autoritativa. Luego ejecutar `/reload`,
`/code-preview-health` y confirmar que todos los tools figuren desactivados.
No aplicar este patch a otra versión sin revisar el diff: el paquete puede haber
incorporado ya la corrección o cambiar sus contextos.

## Renderer Anterior: `pi-claude-code-ui`

`pi-claude-code-ui@1.0.74` agrupa tool rows con estilo Claude Code y registra dos extensiones (`extensions/index.ts` y `extensions/spinner.ts`). Sigue instalada para permitir comparacion/retorno rapido, pero Pi no carga sus extensiones porque `settings.json` contiene:

```json
{
  "source": "npm:pi-claude-code-ui",
  "extensions": []
}
```

No activar ambos renderers al mismo tiempo: los dos intervienen en la presentacion de tools y pueden competir por renderers/overrides.

## Toggle Reversible

Antes de cambiar:

1. respaldar `~/.pi/agent/settings.json`;
2. usar `pi config` o editar solamente las dos entradas de paquetes;
3. ejecutar `/reload`;
4. hacer smoke con `read`, `edit`, `bash` y `Ctrl+O`.

Estado actual:

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
