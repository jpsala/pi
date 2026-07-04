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
  - ../../pi-extensions/pi-footer.json
  - ../../scripts/apply-pi-statusline-customization.ps1
---

# Pi Statusline Customization

Configuracion local de JP para compactar el footer/statusline de Pi sin perder informacion util.

## Objetivo

Mantener una sola linea compacta con:

- modelo, thinking, cwd, git, diff, contexto, ventana de contexto y cache;
- statuses inline: `link`, `win-input`, `chrome`, `usage`;
- sin segunda fila automatica de extension statuses para info ya representada inline;
- si un proyecto publica status propio util (ej. `pi-lens` con `LSP Failed: rust`), mantener solo esa informacion en segunda linea.

Formato esperado aproximado:

```text
gpt-5.5 • think:medium • dir:pi • git:main • (+0,-0) • ctx:30.6% • 272k • cache:2.3M • link: offline • win-input • chrome:∞ • usage:5h:86% · 7d:33% · ↺7d:3d0h
```

## Archivos canonicos en este repo

- `pi-extensions/pi-footer.json`: snapshot versionable de `~/.pi/agent/extensions/pi-footer.json`.
- `scripts/apply-pi-statusline-customization.ps1`: aplica la config y parches locales en una instalacion de Pi.

## Instalacion / restauracion

Desde la raiz de este repo en Windows PowerShell:

```powershell
./scripts/apply-pi-statusline-customization.ps1 -Status
./scripts/apply-pi-statusline-customization.ps1
```

Luego, dentro de Pi:

```text
/reload
```

El script hace backups con sufijo `.bak-pi-statusline-YYYYMMDD-HHMMSS` antes de pisar archivos existentes.

## Resultado validado

Validado en `C:\dev\pi` y `C:\dev\dictation-tauri` tras `/reload`.

Caso `dictation-tauri` con `pi-lens` project-local:

```text
gpt-5.5 • think:high • dir:dictation-tauri • git:main • (+12199,-1241) • ctx:42.7% • 272k • cache:3.6M • link: offline • win-input • chrome:∞ • usage:5h:82% · 7d:33% · ↺7d:3d0h
LSP Failed: rust
```

El duplicado `Codex 5h NN% 7d NN%` ya no aparece; la segunda linea queda reservada para status project-local no duplicado.

## Cambios guardados

### `pi-footer`

Destino instalado:

```text
~/.pi/agent/extensions/pi-footer.json
```

Decisiones:

- `jp-flex` queda deshabilitado para evitar huecos grandes que fuerzan wrap visual.
- `extensionStatusRow.hiddenKeys` oculta `chrome`, `codex-usage`, `codex-usage.compact`, `link`, `telegram`, `windows-input`.
- `link`, `windows-input`, `chrome` y `codex-usage.compact` se renderizan como widgets `external-status` inline en la linea principal.

### `pi-footer` package patch

Destino parcheado:

```text
~/.pi/agent/npm/node_modules/pi-footer/src/index.ts
```

Cambio: filtrar de la fila automatica cualquier status con valor visible tipo `Codex 5h NN% 7d NN%`. Esto evita que una publicacion residual o un key distinto duplique la informacion que ya esta en `codex-usage.compact`, manteniendo otros statuses project-local como `LSP Failed: rust`.

Razon: en `C:\dev\dictation-tauri`, luego de ocultar keys y parchear `pi-codex-usage`, el texto `Codex 5h 18% 7d 67%` seguia apareciendo en la fila automatica. El filtro por valor visible fue la solucion efectiva.

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

### `@calesennett/pi-codex-usage`

Destino parcheado:

```text
~/.pi/agent/npm/node_modules/@calesennett/pi-codex-usage/src/codex-usage/format.ts
```

Cambios:

1. Compactar el status `codex-usage.compact`.
2. No publicar el status completo `codex-usage` en estado normal, para evitar una segunda linea duplicada con la misma informacion en otro formato.
3. `pi-footer` ademas filtra cualquier valor residual tipo `Codex 5h NN% 7d NN%` si aparece bajo otra key.

Antes:

```text
5h 88% left · 7d 34% left · 7d reset 3d0h
Codex 5h 12% 7d 66%
```

Despues:

```text
5h:88% · 7d:34% · ↺7d:3d0h
```

Nota: los porcentajes siguen respetando la preferencia de `pi-codex-usage` (`left` o `used`), pero el compact status no imprime `left`/`used` para ahorrar espacio. Si se cambia a `used`, recordar semanticamente que el porcentaje mostrado pasa a ser usado.

## Despues de actualizar extensiones

Una actualizacion de `pi-chrome`, `pi-footer` o `pi-codex-usage` puede pisar los parches en `node_modules` o cambiar APIs internas. Reaplicar:

```powershell
./scripts/apply-pi-statusline-customization.ps1 -Status
./scripts/apply-pi-statusline-customization.ps1
```

Si el script avisa que un patron no aparece, abrir el archivo upstream y adaptar el parche manualmente; no forzar reemplazos ciegos.

## Diagnostico rapido

Si vuelve a aparecer una segunda linea con `Codex ...`:

1. Ejecutar `/reload`.
2. Reaplicar el restaurador:

   ```powershell
   ./scripts/apply-pi-statusline-customization.ps1
   ```

3. Si persiste, revisar si `pi-footer/src/index.ts` conserva el helper `isDuplicateCodexUsageStatus`.
4. Si aparece una segunda linea solo con `LSP Failed: ...`, no es duplicado: viene de `pi-lens` u otra extension project-local y puede ser util.

## Relacion con windows-input

`windows-input` sigue siendo una extension separada. Este statusline solo muestra su status `win-input` inline cuando la extension lo publica.
