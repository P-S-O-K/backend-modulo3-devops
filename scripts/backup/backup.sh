#!/usr/bin/env bash
set -euo pipefail

# Variables de configuracion
DB_DRIVER="${MY_DATABASE_DRIVER:-postgres}"
DB_HOST="${DB_HOST:?Falta DB_HOST}"
DB_NAME="${DB_NAME:?Falta DB_NAME}"
DB_USER="${DB_USER_NAME:?Falta DB_USER_NAME}"
DB_PASSWORD="${DB_PASSWORD:?Falta DB_PASSWORD}"
DB_PORT="${DB_PORT:-5432}"

S3_BUCKET="${S3_BUCKET:?Falta S3_BUCKET}"
BACKUP_PREFIX="${BACKUP_PREFIX:-paz-soldan/database}"

# Generar fecha y ruta del respaldo
FECHA=$(date -u +"%Y%m%d%H%M%S")
BACKUP_DIR="/tmp/database-backup"
mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/database_${FECHA}.sql"

echo "Iniciando backup de base de datos..."
echo "Motor: $DB_DRIVER"

case "$DB_DRIVER" in
  postgres)
    export PGPASSWORD="$DB_PASSWORD"

    pg_dump \
      -h "$DB_HOST" \
      -p "$DB_PORT" \
      -U "$DB_USER" \
      -d "$DB_NAME" \
      --no-owner \
      --no-acl \
      -f "$BACKUP_FILE"
    ;;

  *)
    echo "ERROR: Motor no soportado por este script: $DB_DRIVER" >&2
    exit 1
    ;;
esac

# Verificar que se genero el archivo
if [ ! -s "$BACKUP_FILE" ]; then
  echo "ERROR: El archivo de backup esta vacio." >&2
  exit 1
fi

# Subir el respaldo a Amazon S3
S3_DESTINO="s3://${S3_BUCKET}/${BACKUP_PREFIX}/${FECHA}/$(basename "$BACKUP_FILE")"

aws s3 cp "$BACKUP_FILE" "$S3_DESTINO"

echo "Backup completado correctamente."
echo "Destino: $S3_DESTINO"

# Eliminar archivo temporal
rm -f "$BACKUP_FILE"
