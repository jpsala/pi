---
id: pi-statusline-customization
status: active
kind: how-to
triggers:
  - pi footer
  - pi statusline
  - chrome status
  - codex usage
  - otra pc
  - actualizar extensiones
primary_refs:
  - ../tracks/pi-ui-usage-evaluation.md
  - ../../pi-extensions/pi-footer.json
  - ../../pi-extensions/pi-openai-usage.json
  - ../../pi-extensions/codex-quota.ts
  - ../../pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch
  - ../../scripts/apply-pi-statusline-customization.ps1
  - ../../scripts/apply-pi-statusline-customization.sh
---

# Pi Statusline Customization

Configuracion local de JP para compactar el footer/statusline de Pi sin perder informacion util.

## Objetivo

Mantener una sola linea compacta con:

- modelo, thinking, cwd, contexto, ventana de contexto y cache;
- statuses inline: `link`, `win-input`, `chrome`, `usage`;
- sin segunda fila automatica de extension statuses para info ya representada inline;
- si un proyecto publica status propio util (ej. `pi-lens` con `LSP Failed: rust`), mantener solo esa informacion en segunda linea.

Formato esperado aproximado:

```text
gpt-5.6-sol • think:high • dir:pi • ctx:30.6% • 272k • cache:2.3M • link: offline • win-input • chrome:∞ • usage:7d: 87% · ↺ 6d2h · margen -2h
```

## Archivos canonicos en este repo

- `pi-extensions/pi-footer.json`: snapshot versionable de `~/.pi/agent/extensions/pi-footer.json`.
- `pi-extensions/pi-openai-usage.json`: snapshot de la salida compacta y polling de `pi-openai-usage`.
- `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch`: margen automatico semanal con los defaults de `/codex-quota`.
- `scripts/apply-pi-statusline-customization.ps1`: copia ambas configs y reaplica los parches locales de `pi-openai-usage`, `pi-footer` y `pi-chrome` en Windows.
- `scripts/apply-pi-statusline-customization.sh`: aplica lo mismo en Linux/macOS, incluyendo VPS.
- El footer consume `openai-usage`, publicado por la version global fijada `pi-openai-usage@0.1.3`. Los restauradores no instalan paquetes: requieren que el productor ya exista.

## Instalacion / restauracion

Desde la raiz de este repo en Windows PowerShell:

```powershell
./scripts/apply-pi-statusline-customization.ps1 -Status
./scripts/apply-pi-statusline-customization.ps1
```

En Linux/macOS/VPS:

```bash
scripts/apply-pi-statusline-customization.sh --status
scripts/apply-pi-statusline-customization.sh
```

Luego, dentro de Pi:

```text
/reload
```

El script hace backups con sufijo `.bak-pi-statusline-YYYYMMDD-HHMMSS` antes de pisar archivos existentes.

## Resultado esperado

`pi-footer` toma el valor publicado bajo `openai-usage` y lo muestra inline con prefijo `usage:`. La segunda linea queda reservada para statuses project-local no duplicados, por ejemplo `LSP Failed: rust`. El smoke RPC mas reciente publico `7d: 87% · ↺ 6d2h · margen -2h`; falta confirmar visualmente el margen despues de `/reload`.

## Cambios guardados

### `pi-footer`

Destino instalado:

```text
~/.pi/agent/extensions/pi-footer.json
```

Decisiones:

- Los widgets de rama y diff Git se omiten porque su consulta degradaba la experiencia en Windows.
- `jp-flex` queda deshabilitado para evitar huecos grandes que fuerzan wrap visual.
- `extensionStatusRow.hiddenKeys` oculta `chrome`, `openai-usage`, `link`, `telegram`, `windows-input` en la fila automatica.
- `link`, `windows-input`, `chrome` y `openai-usage` se renderizan como widgets `external-status` inline en la linea principal.

### `pi-footer` package patch

Destino parcheado:

```text
~/.pi/agent/npm/node_modules/pi-footer/src/index.ts
```

Cambio defensivo: filtrar de la fila automatica valores legacy tipo `Codex 5h NN% 7d NN%`. La key configurada `openai-usage` se oculta en esa fila y se renderiza inline, manteniendo otros statuses project-local como `LSP Failed: rust`.

### `pi-openai-usage` package patch

Destinos parcheados:

```text
~/.pi/agent/npm/node_modules/pi-openai-usage/src/usage-snapshot.ts
~/.pi/agent/npm/node_modules/pi-openai-usage/src/format.ts
```

Patch canonico: `pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch`. Solo aplica a la version fijada `0.1.3`; los restauradores fallan ante otra version para evitar modificaciones ciegas.

### `pi-chrome`

Destino parcheado:

```text
~/.pi/agent/npm/node_modules/pi-chrome/extensions/chrome-profile-bridge/index.ts
```

Cambio: compactar el status publicado por `ctx.ui.setStatus("chrome", ...)`.

Antes:

```text
● Chrome Bridge (indefinite)
```

Despues:

```text
chrome:∞
chrome:15m
chrome:<1m
```

### Fuente de cuota Codex

`@calesennett/pi-codex-usage` fue el productor historico de `codex-usage`; la preferencia legacy `pi-codex-usage.usageMode` puede seguir en `settings.json` sin producir ningun status.

`pi-openai-usage@0.1.3` fue adoptada porque:

- no registra tools LLM ni agrega contexto;
- mantiene cache en memoria y omite requests mientras el snapshot siga fresco;
- usa polling de 10 minutos en esta PC;
- permite configurar ventanas, resets, barras, porcentajes, colores, labels y separadores.

Compatibilidad observada: el endpoint devolvio una sola ventana primaria de 604800 segundos y ninguna secundaria, mientras `0.1.3` llama rigidamente `fiveHour` al slot primario. La config etiqueta ese slot como `7d`, muestra su countdown y oculta los slots secundarios.

El parche local conserva `limit_window_seconds`, identifica la ventana semanal por 604800 segundos y agrega `margen ±Nh` al mismo status, sin otra consulta. Usa la formula/defaults de `codex-quota.ts`: 12 h/dia × 6,5 dias/semana; margen = capacidad restante al ritmo observado menos horas activas planificadas. Si no hay ritmo suficiente muestra `margen --` y si no existe ventana semanal omite el widget.

La extension global `codex-quota.ts` sigue disponible para ver el detalle de ritmo, horas soportadas, presupuesto diario y margen bajo demanda. Su fuente portable canonica vive en `pi-extensions/codex-quota.ts`; cada host instala una copia global sin compartir autenticacion.

Comparacion corta:

| Extension | Recursos | Configuracion | Encaje local |
| --- | --- | --- | --- |
| `pi-openai-usage` | cache en memoria; polling configurable 15s-10m; sin tools LLM | muy alta | recomendada |
| `@narumitw/pi-usage` | cache 5m; auth runtime de Pi | formato casi fijo | robusta, menos editable |
| `pi-codex-status` | inicio + headers oportunistas; cache en disco | baja | eficiente, registra `/status` |
| `@calesennett/pi-codex-usage` | 1m y refresh tras turnos | solo `left/used` | compatible con key legacy, limitada |
| `pi-quota-status` | 1m, estado persistente y reconciliacion CLI | adapters/thresholds | demasiado compleja para solo Codex |

Fuentes principales:

- `pi-openai-usage`: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/README.md#L55-L98>
- cache de `pi-openai-usage`: <https://github.com/studioarray/pi-openai-usage/blob/6c5e40510e7f521663b6078619732596c052dc59/src/usage-refresh-coordinator.ts#L66-L94>
- polling de `@calesennett`: <https://github.com/calesennett/pi-codex-usage/blob/2cef805bc852b3f000763963a004521caa7f3e3f/extensions/codex-usage-status.ts#L22-L45>
- `@narumitw/pi-usage`: <https://github.com/narumiruna/pi-extensions/blob/822ddf011ceeb6846f5da74d3bab6d4ee81e38f0/extensions/pi-usage/README.md#L5-L23>

## Despues de actualizar extensiones

Una reinstalacion de `pi-openai-usage@0.1.3` o una actualizacion de `pi-chrome`/`pi-footer` puede pisar los parches locales. Reaplicar:

```powershell
./scripts/apply-pi-statusline-customization.ps1 -Status
./scripts/apply-pi-statusline-customization.ps1
```

En VPS/Linux:

```bash
scripts/apply-pi-statusline-customization.sh --status
scripts/apply-pi-statusline-customization.sh
```

`-Status`/`--status` falla si alguna config instalada difiere de su snapshot, el widget no consume `openai-usage`, la version no es `0.1.3` o falta el parche de margen. Si cambia la version, adaptar el patch/restaurador; no forzarlo.

## Diagnostico rapido

Si `usage:` desaparece:

1. Ejecutar el chequeo; debe informar keys/configs sincronizadas, `pi-openai-usage version: 0.1.3` y `weekly margin patch is applied`.
2. Si hay drift, reaplicar el restaurador y ejecutar `/reload`.
3. Verificar con `pi list` que `pi-openai-usage@0.1.3` este instalada y no haya otro productor para la misma informacion. `@narumitw/pi-codex-usage` esta deprecada y no debe instalarse.
4. Usar `/openai-usage-settings diagnostics` para validar auth, endpoint, config efectiva y ultimo fetch sin imprimir tokens.
5. Si aparece una segunda linea solo con `LSP Failed: ...`, no es duplicado: viene de `pi-lens` u otra extension project-local y puede ser util.

## Relacion con windows-input

`windows-input` sigue siendo una extension separada. Este statusline solo muestra su status `win-input` inline cuando la extension lo publica.
