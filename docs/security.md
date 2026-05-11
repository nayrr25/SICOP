# Seguridad y publicacion

Propietaria: Nancy Raquel Rodriguez Ramos

Este repositorio esta pensado para ser publico o semi-publico. Por eso debe contener codigo, SQL, documentacion y muestras pequenas, pero no debe contener secretos ni bases completas.

## No subir a GitHub

- Credenciales de Google Cloud.
- Archivos `application_default_credentials.json`.
- Llaves de servicio.
- Tokens de acceso o refresh tokens.
- Archivos `.env`.
- Bases SQLite completas.
- CSV completos del SICOP.
- ZIP descargados del SICOP.
- Exportaciones con datos sensibles no revisados.

## Si se necesita publicar datos

Usar solo:

- Agregados estadisticos.
- Muestras pequenas.
- Datos anonimizados.
- Capturas de dashboard sin informacion sensible.

## Modelo recomendado de acceso

- GitHub publico: codigo, arquitectura, SQL, metodologia.
- BigQuery privado: datos completos y tabla final.
- Dashboard publico: indicadores agregados.
- Dashboard privado: detalle por procedimiento y proveedor.

## Comando de revision antes de subir

```bash
git status --short
find . -type f -size +50M
```

Si aparece un archivo pesado o una credencial, no hacer commit.

