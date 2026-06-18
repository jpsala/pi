# Decisiones

## 2026-06-18 - Inicializar Agentic OS minimo

Decision: crear una capa AOS minima en `C:\dev\pi` con placeholders honestos porque el destino estaba vacio y sin stack detectable.

Motivo: permitir continuidad agentica sin inventar producto, datos, deploy ni runtime.

Consecuencias:

- La memoria durable vive en `docs/`.
- Los adapters `.pi`, `.agents/skills` y SpecKit quedan opcionales hasta que JP los pida o el proyecto los necesite.
- Antes de agregar producto o dependencias, definir el proposito del workspace.
