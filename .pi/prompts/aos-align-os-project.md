---
description: Alinear proyecto registrado con AOS canonico y auditar vision
---
Ejecuta `aos-align-os-project` para el proyecto indicado (o pedime elegir si falta): leer `docs/OS_PROJECTS.md`, verificar path/capas/git status del target, aplicar `aos-update-os` o `aos-adopt-os` segun estado, luego `aos-perfect-os` para alinear contenido con la vision AOS. No pisar memoria local ni tocar producto/datos/deploy sin confirmacion. Regenerar indice/audit del target si existen y actualizar el registry con fecha, capas, resultado y proximo paso. Reportar aplicado, omitido, conflictos, drift restante y checks.
