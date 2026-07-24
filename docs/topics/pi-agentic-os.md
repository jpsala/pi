---
id: pi-agentic-os
status: active
kind: how-to
triggers:
  - pi os
  - pi agentic os
  - /flow
  - pensar
  - planear
  - hacer
  - cerrar
  - ask_user
  - advisor
  - pi-lens
  - computer use
primary_refs:
  - aos.requirements.json
  - C:/dev/os/runtime/aos-flujo.ts
  - C:/dev/os/docs/topics/pi-agentic-os.md
  - docs/topics/pi-extension-stack.md
  - docs/topics/agent-tool-routing.md
  - docs/reference/tool-routing.yaml
---

# Pi Agentic OS

`C:/dev/pi` consume el `/flow` global canónico de `C:/dev/os`; no publica
runtime, prompts de lifecycle ni comandos AOS locales. Este repo conserva sólo
customizaciones Pi portables de JP.

## Superficie Canónica

| Entrada | Uso |
| --- | --- |
| `/flow → Pensar` | Explorar y converger decisiones en el hilo actual. |
| `/flow → Planear` | Crear un brief durable y registrar un único foco. |
| `/flow → Hacer` | Abrir una sesión nueva enlazada, precargar el handoff documental y ejecutar directamente allí. |
| `/flow → Cerrar` | Compactar valor durable todavía faltante; es opcional si Hacer ya persistió el estado. |
| `/new` | Abrir manualmente una sesión limpia fuera del handoff de Hacer. |

`/flow` precarga texto revisable y nunca autoenvía. Planear declara en el brief
`execution_route: economical | balanced | strong`: `economical` usa Luna High
para docs o mecánica de bajo riesgo, `balanced` usa Sol Medium por defecto y
`strong` usa Sol High para trabajo sensible. Hacer exige foco `ready`: 0 deriva
a Planear, 1 autoselecciona y N abre picker. La sesión nueva aplica la ruta antes
de precargar índice, Working Memory y brief; modelo o auth ausentes bloquean sin
fallback. No promete transportar conversación transitoria y ejecuta en ese hilo
principal, sin Agent ni otra sesión.

## Contrato Global

- `aos.requirements.json` exige `aos.flow-first@1.1.0`, scope `user` y
  cardinalidad 1.
- El runtime efectivo debe ser `C:/dev/os/runtime/aos-flujo.ts`, origin
  `package`, sin `.pi/extensions/aos-flujo.ts` local.
- `scripts/agent-context-audit.ts` valida package, requisitos y ausencia de copia.
- Init/adopt/update/align/perfect/realinear son operaciones manager-only de
  `C:/dev/os`, no slash commands diarios de este workspace.

## Customizaciones Locales

Windows Input, footer/statusline y UX compacta se mantienen en `pi-extensions/`
y sus scripts. No confundir esas fuentes portables con gobierno AOS o inventario
global. Aplicar configuraciones globales requiere autorización, backup y smoke.

## Flujo

Índice → Working Memory → contexto puntual → `/flow → Hacer` → sesión enlazada →
un batch → checks/diff → persistencia final. Usar `/flow → Cerrar` sólo si quedó
continuidad durable pendiente. Browser, hotkeys, clipboard o UI visible requieren
el aviso inicial; installs, credenciales, commit, push, deploy, producción y
destrucción mantienen gates separados.
