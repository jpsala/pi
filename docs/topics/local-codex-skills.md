---
id: local-codex-skills
status: reference
kind: decision-map
triggers:
  - skills locales
  - local skills
  - slash commands
  - docs/skills
  - .agents/skills
  - toggle skills
  - skills on
  - skills off
  - os help
  - perfect os
  - init os
  - adopt os
  - update os
  - sigamos
  - guardar sesion
  - documentar sesion
  - checkpoint
  - persistir estado
  - cerrar sesion
  - continuar
  - prompt de continuidad
  - realinear os
  - evaluar skills
  - hacer commits
  - push
  - publicar cambios
  - incluir todo en la repo
  - repo commit push
  - ejecutar lote
  - proximo lote
  - avancemos
  - orquestar
  - aos-orquestar
  - aos-fanout
  - aos-fleet-update
  - aos-threads
  - usar threads
  - spawn agents
  - subagentes
  - until-done
  - pasar a skills
  - promover a skill
  - que se puede pasar a skills
  - skill o topic
  - metadata mínima
  - metadata minima
  - modelo hibrido
primary_refs:
  - docs/skills/README.md
  - docs/skills/
  - AGENTS.md
  - docs/WORKING_MEMORY.md
  - scripts/ensure-skills-link.ps1
  - scripts/toggle-skills-link.ps1
  - scripts/agent-context-audit.ts
---

# Skills Locales De Codex

## Uso

Abrir este topic solo cuando el usuario pregunte por skills locales, slash commands, metadata, discovery, costo de tokens, o cuando haya que crear o revisar una skill.

No abrirlo durante trabajo normal del repo ni durante `guardar sesion`/`nueva sesion` salvo que el problema involucre skills.

## Regla Canonica

Las skills AOS portables se consultan en `C:/dev/os/docs/skills/`; este repo conserva en `docs/skills/` solo aliases locales no colisionantes.

`.agents/skills` existe solo como compatibilidad tecnica y debe apuntar por junction o symlink a la superficie local mientras esta no este vacia.

No recrear localmente una skill portable para limpiar la paleta: el path canonico es `C:/dev/os/docs/skills/`.

No duplicar la misma skill en dos carpetas reales.

## Skill, Topic O Regla Activa

No todo lo que vive en memoria activa debe convertirse en skill.

Usar esta regla:

| Tipo          | Usar cuando                                                                      | Costo                                | Ejemplo                                            |
| ------------- | -------------------------------------------------------------------------------- | ------------------------------------ | -------------------------------------------------- |
| Regla activa  | Debe condicionar todo trabajo y no es un comando.                                | Alto pero necesario.                 | No commitear secretos, no revertir cambios ajenos. |
| Topic         | Es conocimiento recuperable, criterio o explicacion.                             | Bajo demanda.                        | Como decidir donde poner memoria durable.          |
| Skill         | Es una accion invocable, repetible y estable.                                    | Metadata siempre descubierta.        | `cerrar sesion`, `realinear os`.                   |
| Skill hibrida | Se quiere descubrimiento por nombre, pero la logica vive en docs/topics/scripts. | Metadata chica + referencia externa. | `crear-track`, `regenerar-contexto`.               |

Una instruccion activa puede funcionar como skill si tiene forma de accion. No conviene convertir reglas globales de seguridad o lectura en skills solo para nombrarlas.

## Modelo Hibrido

El modelo recomendado para comandos operativos nuevos es hibrido:

1. La skill existe para hacer descubrible el comando.
2. El `SKILL.md` se mantiene corto.
3. La logica durable vive en `AGENTS.md`, topic, track, spec o script.
4. La skill apunta a la fuente canonica y no duplica procedimiento largo.
5. Si cambia la logica, se actualiza la fuente canonica y se revisa si la skill sigue apuntando bien.

Esto permite usar skills como superficie de invocacion sin mover todo el sistema agentico a `docs/skills/`.

### Metadata Minima

Una skill con metadata minima es aceptable cuando:

- el nombre del comando ya es claro;
- el comportamiento canonico vive en un topic o script;
- el objetivo principal es que Codex descubra el comando;
- repetir el procedimiento dentro del `SKILL.md` aumentaria drift.

Formato recomendado:

```markdown
---
name: crear-track
description: Create a new AOS track from the canonical template and current work context. Use when the user says `crear track` or wants a resumable work item.
---

# Crear Track

Abrir `docs/topics/docs-knowledge-system.md` y `docs/tracks/TEMPLATE.md`.
Crear o actualizar la track siguiendo esas fuentes canonicas.
```

No usar metadata minima cuando el comando es riesgoso, tiene muchos pasos fragiles o requiere validacion precisa. En esos casos el `SKILL.md` debe tener guardrails suficientes o delegar a un script.

## Criterio De Promocion

Antes de crear una skill nueva, responder:

1. El usuario podria invocarlo por nombre?
2. Es una accion repetible, no solo una politica?
3. Tiene triggers claros?
4. Su logica puede vivir en una fuente canonica sin duplicarse?
5. El costo de metadata se justifica por descubribilidad?

Si la respuesta fuerte es "si" en 3 o mas puntos, crear skill. Si no, dejarlo como topic, regla activa o track.

## Auditoria De Candidatos

Cuando JP pida revisar que del sistema agentico se puede pasar a skills:

1. Usar la skill `aos-evaluar-skills`.
2. Leer ruta liviana: indice, working memory y topics.
3. Buscar candidatos en `AGENTS.md`, `docs/TOPICS.md`, `docs/topics/`, `docs/tracks/` y `docs/skills/README.md`.
4. Proponer shortlist con recomendacion: `skill`, `skill hibrida`, `topic`, `regla activa`, `track` o `no promover`.
5. Implementar solo despues de confirmar o si JP pide "hacelo".

## Comandos Cubiertos

- `os help` / `ayuda os` / `comandos os`
- `perfect os` / `dejar en condiciones`
- `init os` / `adopt os` / `update os`
- `aos-sigamos`
- `avancemos` / siguiente paso en esta sesion
- `aos-orquestar` / `aos-fanout` / `aos-threads` / `orquestá` / `usá threads`
- `guardar sesion` / `documentar sesion`
- `aos-checkpoint` / `persistir estado` / `cerrar sesion` aliases
- `/aos-continuar` para abrir sesion nueva desde docs vivos despues de guardar
- `realinear os`
- `evaluar skills`
- `repo commit push`
- `hacer commits` / `push` / `publicar cambios`
- Herramientas de planificación/implementación Pi: no crear skill nueva; rutear a `docs/topics/pi-extension-stack.md` o al topic local equivalente.

## Mapa De Skills

| Comando o grupo                                                       | Skill                                                          | Comportamiento                                                                                                 |
| --------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Comandos AOS portables (`aos-*`) | `C:/dev/os/docs/skills/` | Fuente canonica upstream; no duplicar localmente. |
| Pi planning tools, advisor, taskflow, dgoal, pi-lens, pi-code-planner | `docs/topics/pi-extension-stack.md` | No es skill nueva: topic/runbook canonico para elegir herramientas de pensamiento/implementación. |
| `/aos-continuar [objetivo]` | `.pi/extensions/aos-tools.ts` + `.pi/prompts/aos-continuar.md` | Abre sesion Pi nueva y pasa un prompt de continuidad desde docs vivos; JP debe haber guardado antes. |

## Validacion

1. Verificar o alternar el enlace tecnico:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 on
# `off`/`toggle` quedan como aliases legacy no destructivos.
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
```

`off` y `toggle` ya no remueven el junction/symlink `.agents/skills`; lo mantienen o lo reparan para evitar paths cacheados rotos.

1. Validar una skill o todas las necesarias:

```powershell
python C:\dev\agent-infra\rules\skills\.system\skill-creator\scripts\quick_validate.py C:/dev/os/docs/skills/aos-sigamos
python C:\dev\agent-infra\rules\skills\.system\skill-creator\scripts\quick_validate.py C:/dev/os/docs/skills/aos-realinear-os
```

1. Regenerar indice y correr audit:

```powershell
bun run context:index
bun run context:audit
```

## Mantenimiento

- Las skills portables se editan upstream en `C:/dev/os/docs/skills/<nombre>/`.
- Si se agrega una skill local no colisionante, indexarla desde `docs/skills/README.md`; actualizar este topic solo si cambia el criterio de diseño o mantenimiento.
- Si una skill necesita metadata UI, mantener `agents/openai.yaml` alineado con `SKILL.md`.
- Preferir skills hibridas cortas cuando ya existe una fuente canonica confiable.
- Si Git empieza a detectar ruido por la compatibilidad tecnica, mantener `.agents/skills/` ignorado.
- Para trabajar con Codex, habilitar discovery con `bun run skills:on` o `scripts/toggle-skills-link.ps1 on`.
- Para trabajar con Pi, mantener `.agents/skills` estable; `/aos-skills off` y `scripts/toggle-skills-link.ps1 off` son aliases legacy no destructivos.
- Despues de portar o mover el repo, correr `scripts/ensure-skills-link.ps1`. Si `.agents/skills` llego como carpeta real, el script debe preservarla como backup, copiar skills faltantes a `docs/skills/` y recrear el junction.
