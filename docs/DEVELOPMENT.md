# Desarrollo

## Stack

Pendiente. En el init OS no se detectaron archivos de stack (`package.json`, `pyproject.toml`, `Cargo.toml`, README de producto ni git repo).

## Comandos Disponibles

```powershell
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
powershell -ExecutionPolicy Bypass -File scripts/toggle-skills-link.ps1 status
powershell -ExecutionPolicy Bypass -File scripts/ensure-skills-link.ps1
```

Linux/VPS sin PowerShell:

```bash
mkdir -p .agents
ln -sfn ../docs/skills .agents/skills
bun scripts/context-index.ts
bun scripts/agent-context-audit.ts
```

## Entornos Conocidos

- Local Windows: `C:\dev\pi`.
- VPS via SSH `vps`: `/home/jpsal/dev/pi`, equivalente a `C:\dev\pi`.
- En VPS, `pi` debe resolver a `~/.local/bin/pi` antes que `/usr/bin/pi`; ver `docs/topics/pi-agentic-os.md`.

## Persistencia Y Datos

No hay persistencia de producto definida. No crear storage, datos operativos ni deploy sin confirmacion.
