---
status: done
started: 2026-07-31
updated: 2026-07-31
priority: high
owner: JP
related:
  - ../topics/pi-statusline-customization.md
  - ../topics/pi-extension-stack.md
---

# Pi Startup Alternatives

Investigacion para bajar el arranque de Pi 0.83.0 sin perder informacion util.
La investigacion termino, el cambio global fue aplicado con autorizacion y el
smoke humano confirmo una mejora material despues de `/reload`.

## Metodo

Benchmark local en Windows con `PI_OFFLINE=1`, `PI_SKIP_VERSION_CHECK=1` y
`pi --no-extensions -e <entrypoint> --list-models gpt-5.6-sol`. Cinco corridas
calientes por variante. Los candidatos con repositorio disponible se cargaron
directamente desde el checkout temporal de investigacion, sin instalarlos.

## Footer/statusline

| Candidato | Mediana | Extra sobre baseline | Observacion |
| --- | ---: | ---: | --- |
| Sin extension / footer nativo | 1,326 s | — | Menor costo y cero mantenimiento. |
| Footer minimo local estilo ejemplo oficial | 1,362 s | +0,036 s | Mantiene sólo los datos elegidos y statuses genericos. |
| `pi-inline-statusline@0.17.1` | 1,497 s | +0,171 s | Preserva statuses genericos, una linea con wrap por segmentos, sin dependencias runtime. |
| `@feniix/pi-statusline@0.5.3` | 1,500 s | +0,174 s | Dos lineas; no documenta consumo de statuses genericos. |
| `pi-footer@0.5.0` actual | 4,275 s | +2,949 s | Principal cuello de botella. |

Causa de `pi-footer`: publica 115 archivos TypeScript (~247 KB) y el entrypoint
importa eager la UI de configuracion y el registro completo de widgets. Jiti debe
resolver/transpilar ese grafo en cada proceso aunque el preset use pocos widgets.
No es polling: `pi-openai-usage` y `pi-chrome` quedaron dentro del ruido de carga.

Candidatos descartados para este objetivo:

- `pi-powerline-footer`: agrega editor, bash persistente, welcome overlay y vibes;
  demasiado alcance para sólo un footer rapido.
- `statusline-pi`: consulta CPU/memoria y git cada 5 s y PR cada 60 s.
- `pi-infobar`: duplica consulta de cuota Codex y pesa ~974 KB.
- `@shvax/pi-statusline`: vuelve a consultar cuotas de varios providers cada 10 s.
- `pi-bar`: compacto y conserva statuses, pero su progreso puede invocar otro
  modelo; no conviene para reducir complejidad salvo que se desactive ese segmento.
- `@wierdbytes/pi-statusline` y forks: incluyen editor fijo, stash y bridges;
  más superficie que la requerida.

Recomendacion escalonada:

1. Desactivar `pi-footer` y probar primero el footer nativo de Pi.
2. Si el nativo pierde demasiada informacion, usar un footer minimo local.
3. Si se prefiere un paquete mantenido externamente, probar
   `pi-inline-statusline@0.17.1`.

Fuentes principales:

- <https://pi.dev/packages/pi-inline-statusline>
- <https://pi.dev/packages/@narumitw/pi-statusline>
- <https://pi.dev/packages/@odinlayer/pi-statusbar>
- <https://pi.dev/packages/@feniix/pi-statusline>
- <https://pi.dev/packages/pi-bar>
- ejemplo oficial: <https://github.com/earendil-works/pi/blob/main/packages/coding-agent/examples/extensions/custom-footer.ts>

## Subagents

| Candidato | Mediana | Extra sobre baseline | Observacion |
| --- | ---: | ---: | --- |
| Sin subagent | 1,326 s | — | Recomendado mientras no se use. |
| Ejemplo oficial de Pi | 1,365 s | +0,039 s | Rapido, pero es ejemplo y no paquete soportado. |
| `pi-sub-agent@0.1.5` | 1,398 s | +0,072 s | Simple; single/parallel/chain; cero dependencias runtime. |
| `pi-subagents-lite@1.6.0` actual | 2,783 s | +1,457 s | Costo alto para una capacidad inactiva. |

Causa de `pi-subagents-lite`: el entrypoint alcanza eager 48 archivos TypeScript
(~389 KB), incluyendo menus, widget, viewer, manager, runner y configuracion. La
extension registra toda esa superficie al cargar aunque no se invoque un agente.
Tambien declara `pi-agent-core` y TypeBox como dependencias runtime.

Alternativas revisadas:

- `pi-sub-agent@0.1.5`: mejor candidato estable y liviano si vuelve a necesitarse;
  agentes aislados, single/parallel/chain, guard de recursion y confirmacion para
  agentes project-local.
- `pi-simple-agents@0.9.1`: mas configurable, pero agrega `glob`, `yaml` y `zod`;
  no es la opcion minima.
- `pi-subagents@0.38.0`, `@narumitw/pi-subagents` y `pi-cohort`: muy completos
  (async, fleet, watchdog, chains), pero no encajan con una capacidad casi nunca
  usada ni con el objetivo de arranque minimo.

Decision de JP: desactivar `pi-subagents-lite` e instalar la alternativa medida
`pi-sub-agent@0.1.5`.

Fuentes principales:

- <https://pi.dev/packages/pi-sub-agent>
- <https://pi.dev/packages/pi-subagents>
- <https://pi.dev/packages/@narumitw/pi-subagents>
- <https://pi.dev/packages/pi-simple-agents>
- ejemplo oficial: <https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent>

## Aplicacion Y Verificacion

Batch autorizado y ejecutado:

- backup: `~/.pi/agent/backups/pi-startup-trim-20260731-155743/`;
- `pi-footer` queda instalado pero filtrado con `extensions: []`;
- `pi-subagents-lite` queda instalado pero filtrado con `extensions: []`;
- instalado global y fijado: `npm:pi-sub-agent@0.1.5`;
- `pi list` confirma ambos anteriores como `filtered` y el reemplazo activo;
- RPC confirma `/sub-agent-settings` desde `pi-sub-agent` y no lista comandos de
  `pi-footer` ni `pi-subagents-lite`;
- benchmark post-cambio estabilizado alrededor de 3,2 s en las últimas corridas,
  frente a 7,29 s antes del cambio (~4,1 s / 56% menos). Las corridas de Windows
  tuvieron ruido por carga concurrente, por lo que el delta aislado por entrypoint
  sigue siendo la evidencia comparativa principal.

La instalacion reporto las mismas dos vulnerabilidades agregadas del arbol npm
(1 moderate, 1 high); `pi-sub-agent` no declara dependencias runtime. No se ejecuto
`npm audit fix`. Un `npm audit --omit=dev` posterior no pudo correr porque el
store de Pi no tiene lockfile.

Rollback:

```powershell
pi remove npm:pi-sub-agent
Copy-Item "$env:USERPROFILE/.pi/agent/backups/pi-startup-trim-20260731-155743/settings.json" "$env:USERPROFILE/.pi/agent/settings.json" -Force
```

Luego `/reload`.

## Reperfilado Y Cierre

El smoke humano posterior a `/reload` confirmo que el arranque se siente
materialmente mas rapido. La captura mostro footer nativo, `openai-usage` y
`win-input`; `pi list` confirmo `pi-footer` y `pi-subagents-lite` filtrados y
`pi-sub-agent@0.1.5` activo.

Reperfilado comparable con 7 corridas calientes e intercaladas:

| Variante | Mediana | Rango |
| --- | ---: | ---: |
| Sin extensiones | 1,379 s | 1,326-1,840 s |
| Stack global efectivo | 3,854 s | 3,263-5,294 s |

Contra los 7,29 s previos, la mediana actual bajo 3,44 s, aproximadamente 47%.
La medicion post-cambio inicial de ~3,2 s queda dentro del ruido observado en
Windows; la conclusion estable es que se elimino cerca de la mitad del arranque,
no que cada inicio deba durar exactamente lo mismo.

El aislamiento actual tampoco encontro un nuevo cuello dominante: con cinco
corridas ruidosas, `pi-sub-agent` marco 2,031 s, `pi-openai-usage` 1,502 s y
`pi-compact-transcript` 1,575 s frente a baseline 1,788 s. Esos numeros no son
aditivos y solo descartan un costo aislado comparable al antiguo `pi-footer`.
Habia nueve procesos Pi abiertos, con ~1,94 GiB de working set combinado, factor
probable de la dispersion entre corridas pero no de la mejora contra el baseline
anterior medido bajo condiciones equivalentes.

## Auditoria Del Tiempo Residual

Una segunda auditoria con cinco corridas intercaladas separo el costo fijo del
stack actual:

| Variante | Mediana | Parte del arranque |
| --- | ---: | ---: |
| Stack efectivo | 3,186 s | 100% |
| Sin extensiones | 1,348 s | 42% |
| Extensiones activas, por diferencia | 1,838 s | 58% |

Desactivar skills, context files, prompts o themes por separado o en conjunto no
redujo la mediana fuera del ruido. El tiempo residual no esta en AGENTS, docs ni
catálogos de skills: sigue concentrado en cargar extensiones.

Un CPU profile de tres arranques, comparado con tres sin extensiones, mostro que
el incremento ocurre casi por completo dentro de Jiti y del loader de modulos/FS
de Node. El stack activo tiene 18 entrypoints, 16 de ellos TypeScript cargados en
arranque. En el perfil agregado, Jiti fue la URL individual dominante y el codigo
directo de las extensiones represento menos del 2% del CPU incremental; el costo
es principalmente resolver, leer, transformar y enlazar muchos modulos, no
polling ni trabajo de negocio posterior.

La atribucion individual ya esta cerca del piso de ruido de Windows. Los unicos
indicios repetibles fueron CodeMapper (~0,18-0,27 s al omitirlo) y Pi Lens
(~0,30 s de mediana, con dispersion alta); `pi-ask-user` rondo ~0,08 s. Para el
resto, las diferencias leave-one-out fueron inconsistentes o menores a ~0,1 s,
por lo que no corresponde inventar un ranking fino. El aislamiento de
`pi-rtk-optimizer` parecio caro en frio, pero no ahorro tiempo dentro del stack
completo y queda no confirmado.

Conclusion: despues de retirar los dos cuellos grandes, no queda otra extension
de varios segundos. Queda un impuesto acumulativo de ~1,8 s por cargar muchas
extensiones, mas ~1,35 s de core/model catalog/Node. La proxima mejora real debe
venir de menos entrypoints always-on, loaders livianos/deferred o distribuciones
JS precompiladas; recortar docs o polling no atacaria el costo observado.
