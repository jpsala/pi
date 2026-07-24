# Proyecto

## Identidad

- Nombre: `pi`.
- Propósito: ser el laboratorio durable, portable y reversible de customizaciones Pi de JP.
- Estado: workspace activo para probar, instalar, desactivar, comparar, parchear y restaurar extensiones, UI, input, statusline y capacidades basadas en APIs.

## Alcance

- fuentes propias, patches, configs saneadas, snapshots y restauradores;
- registro de extensiones Pi instaladas, evaluadas, activas, desactivadas o retiradas cuando formen parte de un experimento local;
- scripts de instalación, aplicación, toggles, smoke, backup y rollback;
- investigación y comportamiento observado de APIs usadas por esas customizaciones;
- documentación suficiente para retomar, reproducir, cambiar de opción o volver atrás;
- declaración downstream del `/flow` global de `C:/dev/os`.

`C:/dev/os` conserva el runtime `/flow`, routing e inventario global general. Este repo registra el estado y la historia de las extensiones/configuraciones Pi que JP prueba o personaliza aquí. No es producto, runtime AOS ni gestor de infraestructura.

## No Hacer

- No duplicar runtime, routing, registry, tracks o skills manager-only de AOS.
- No convertir el registro local de experimentos en una copia completa del inventario global de `C:/dev/os`.
- No aplicar settings ni instalar paquetes sin autorización y backup.
- No crear deploy, storage o runtime externo.
- No guardar `node_modules`, tokens, `auth.json`, respuestas privadas de APIs, secretos ni datos sensibles; persistir sólo evidencia resumida y saneada.
