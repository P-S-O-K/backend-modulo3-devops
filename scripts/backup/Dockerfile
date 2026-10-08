
FROM postgres:16-bookworm

# Instalar AWS CLI y certificados
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       awscli \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar el script de respaldo
COPY backup.sh /usr/local/bin/backup.sh

# Dar permisos de ejecucion
RUN chmod +x /usr/local/bin/backup.sh

# Ejecutar el script al iniciar el contenedor
ENTRYPOINT ["/usr/local/bin/backup.sh"]
