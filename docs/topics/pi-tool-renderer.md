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
| Transcript colapsado | `pi-compact-transcript@0.6.2` | una línea para todas las tools, incluidas custom/externas |
| Detalle expandido built-in | `pi-code-previews@0.1.36` | renderer original disponible con `Ctrl+O` |
| Intento retirado | `pi-tool-display@0.5.0` | instalado pero fuera de `settings.json`; no puede decorar tools de otras extensiones en Pi 0.82.1 |
| Renderer anterior | `pi-claude-code-ui@1.0.74` | instalado pero desactivado con `extensions: []` |

## Reparto Efectivo Ultra Compacto

El modo global adoptado el 2026-07-25 es:

- `pi-compact-transcript` reemplaza sólo la presentación colapsada de cualquier tool por una línea y agrupa ráfagas consecutivas;
- al expandir con `Ctrl+O`, vuelve al renderer original de la tool;
- `pi-code-previews` conserva el detalle expandido de las siete built-ins;
- FFF, CodeMapper, Pi Lens y futuras tools custom quedan cubiertas sin una lista por nombre;
- `hideThinkingBlock: true` y `outputPad: 0` completan el modo compacto.

La instalación es global en `~/.pi/agent`, por lo que aplica a todos los proyectos de esta PC. Cada sesión ya abierta requiere `/reload`; una sesión puede alternarlo con `/compact-transcript on|off`.

## Causa Del Fallo Anterior

Los smokes visuales mostraron `expand` crudo en Constelaciones y `ffgrep` extenso en Copicu aunque `pi-tool-display` declaraba esos nombres en `summary`. El orden de paquetes no era la causa suficiente:

- Pi 0.82.1 entrega una instancia aislada de `ExtensionAPI` a cada extensión;
- `pi.getAllTools()` expone metadata, no `execute`, `renderCall` ni `renderResult`;
- por eso una extensión no puede reemplazar públicamente el renderer de una tool registrada por otra;
- Pi mantiene abierta la solicitud de una API de render-only para resolver exactamente este caso.

`pi-tool-display@0.5.0` es la última versión publicada y sus peers declarados llegan sólo hasta Pi 0.80. Se retiró de `settings.json`, pero quedó instalado junto con su config/snapshot para rollback y análisis histórico.

## Adopción Y Evidencia

Paquete adoptado: `pi-compact-transcript@0.6.2`, publicado en npm y mantenido como extensión independiente. Su comportamiento declarado cubre tools externas y conserva el renderer original al expandir.

Validación local:

- `/compact-transcript` aparece por RPC desde `npm:pi-compact-transcript@0.6.2`, scope global, sin `extension_error`;
- un probe runtime creó una tool custom con renderer propio de 100 líneas: colapsada produjo exactamente 1 línea y expandida 104 líneas;
- `hideThinkingBlock` sigue en `true` y `outputPad` en `0`;
- se auditaron 19 `C:/dev/**/.pi/settings.json`: ninguno deshabilita recursos globales, por lo que Copicu, Constelaciones y los demás proyectos heredan el paquete;
- SHA-256 instalado de `extensions/compact-transcript.ts`: `43112198015f5b660c575bbd726f827e77169baf60a3ff607a9d37b300f2a1df`;
- backup inmediato: `~/.pi/agent/backups/pi-compact-transcript-20260725-202053/`;
- `npm audit` quedó igual antes y después: 1 moderate (`protobufjs`) y 1 high (`brace-expansion`), ambos transitivos; no se ejecutó `npm audit fix`.

Riesgo: la compactación de filas usa internals actuales de la TUI porque Pi aún no ofrece un hook público global. Si una actualización de Pi cambia esos internals, la extensión cae al renderer normal sin alterar ejecución ni output enviado al modelo. Después de actualizar Pi, repetir un smoke custom colapsado/expandido.

Rollback rápido:

```powershell
Copy-Item "$env:USERPROFILE\.pi\agent\backups\pi-compact-transcript-20260725-202053\settings.json" "$env:USERPROFILE\.pi\agent\settings.json" -Force
```

Luego `/reload`. El paquete puede quedar instalado pero inactivo; removerlo requiere autorización explícita.

Fuentes:

- comportamiento para tools custom y expansión: <https://github.com/avhagedorn/pi-compact-transcript/blob/abf969c69052cc69419a806fddc5b350ee7e57e0/README.md#L13-L20>;
- implementación colapsada y fallback expandido: <https://github.com/avhagedorn/pi-compact-transcript/blob/abf969c69052cc69419a806fddc5b350ee7e57e0/extensions/compact-transcript.ts#L565-L644>;
- limitación oficial de renderers entre extensiones: <https://github.com/earendil-works/pi/issues/3541>.

## Sync VPS 2026-07-25

El commit `58e0582` quedó publicado y `~/dev/pi` avanzó por fast-forward. El VPS quedó en Pi `0.82.1` y con las mismas versiones comunes de la PC, incluidos `pi-footer@0.5.0`, `rpiv-advisor@2.1.0`, `pi-code-previews@0.1.36` upstream limpio y `pi-tool-display@0.5.0`.

Se copiaron ambos snapshots con hashes idénticos, se preservó el orden `tool-display → pi-fff → code-previews`, se retiraron peers npm innecesarios y se reiniciaron sólo `pi-web-sessiond.service` y `pi-web.service`. RPC: un `/flow`, sin `aos-gol`, ambos renderers presentes y cero `extension_error`; `pi-web doctor` pasó. Esa paridad antecede la ampliación posterior de overrides a CodeMapper/Lens: el VPS queda pendiente de una sincronización separada y autorizada. Backup remoto:

```text
/home/jpsal/.pi/agent/backups/pi-ultra-compact-parity-20260725-145903/
```

`npm audit --omit=peer` reportó 9 advisories transitivos (8 moderate, 1 high); no se ejecutó `npm audit fix`.

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
"npm:pi-compact-transcript@0.6.2"
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

`pi-tool-display@0.5.0` permanece instalado, pero no figura en `packages` y por tanto no carga.

Para volver temporalmente al renderer anterior, deshabilitar `pi-compact-transcript`, habilitar `pi-claude-code-ui` y deshabilitar sólo los recursos de `pi-code-previews`:

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

Ese `settings.json` es una referencia del estado anterior, no debe restaurarse completo ahora porque fue creado antes de cambios globales posteriores como `pi-openai-usage`. Para el rollback actual usar primero `pi-compact-transcript-20260725-202053`; para alternar manualmente, modificar sólo las entradas de estos renderers y luego `/reload`.

Si `pi-code-previews` falla:

1. deshabilitar sus recursos;
2. habilitar `pi-claude-code-ui` o dejar ambos deshabilitados;
3. `/reload`;
4. verificar que exista un solo dueño visual por tool.
