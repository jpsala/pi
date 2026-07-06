# Decisiones

## 2026-06-18 - Inicializar Agentic OS minimo

Decision: crear una capa AOS minima en `C:\dev\pi` con placeholders honestos porque el destino estaba vacio y sin stack detectable.

Motivo: permitir continuidad agentica sin inventar producto, datos, deploy ni runtime.

Consecuencias:

- La memoria durable vive en `docs/`.
- Los adapters `.pi`, `.agents/skills` y SpecKit quedan opcionales hasta que JP los pida o el proyecto los necesite.
- Antes de agregar producto o dependencias, definir el proposito del workspace.

### 2026-07-04 - Usar internet libremente y pedir permiso antes de instalar

Estado: accepted

Decision: los agentes deben usar web/internet libremente por defecto cuando conocimiento externo o cambiante evite adivinar, priorizando fuentes oficiales y sin enviar secretos, `.env`, codigo privado sensible, datos personales ni credenciales. Si evidencia online contradice el repo local, docs del proyecto o comportamiento observado, deben consultar a JP antes de decidir y presentar ambas evidencias con fuentes e impacto. Para instalar dependencias, CLIs, paquetes de sistema, herramientas auxiliares o binarios/scripts remotos, deben pedir autorizacion explicita con comando exacto, alcance, motivo, riesgos, alternativas, cambios esperados y rollback.

Motivo: JP quiere recuperar poder agente usando conocimiento disponible en internet en vez de inferir de memoria, pero conservar control humano sobre cambios de entorno/instalaciones y sobre conflictos entre fuentes externas y realidad local.

Proximo paso: aplicar la politica desde `AGENTS.md` y `docs/topics/pi-agentic-os.md`.

### 2026-07-04 - Simplificar continuidad Pi a `/aos-continuar` post-guardado

Estado: accepted

Decision: AOS deja un unico comando Pi para abrir una sesion/thread nuevo: `/aos-continuar [objetivo]`. JP se hace cargo de correr `/aos-guardar-sesion` primero cuando haya valor durable. `/aos-continuar` no guarda, no compacta, no ejecuta `gol` y no duplica docs: crea una sesion nueva con `ctx.newSession()` y le pasa un prompt de continuidad que referencia `docs/.generated/context-index.md`, `docs/WORKING_MEMORY.md`, `docs/TOPICS.md`, topic/track/spec puntual y estado git. `--preview` abre la sesion nueva con el prompt en el editor sin enviarlo automaticamente.

Motivo: los comandos previos (`/aos-nueva-sesion`, `/aos-continuar-sesion`, `/aos-nueva-sesion-con-gol`, `/aos-continuar-con-gol`, `/aos-siguiente`) mezclaban guardado, handoff y ejecucion, generando ambiguedad. JP quiere revisar/controlar el guardado por separado y tener una continuidad confiable basada en docs vivos.

Proximo paso: usar `/aos-continuar` despues de `/aos-guardar-sesion` y ejecutar `/reload` tras actualizar el adapter Pi.

