#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/jenkins-install.log) 2>&1

# 1. Actualizar e instalar dependencias
apt-get update
apt-get install -y ca-certificates curl gnupg

# 2. Instalar Docker Engine en EC2
curl -fsSL https://get.docker.com | sh
systemctl enable --now docker

# 3. Crear directorio para la imagen personalizada
mkdir -p /opt/jenkins-custom

# 4. Crear Dockerfile con Node.js, npm y Docker CLI
cat > /opt/jenkins-custom/Dockerfile <<'DOCKERFILE'
FROM jenkins/jenkins:lts-jdk21

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    rm -rf /var/lib/apt/lists/*

# Node.js 22 y npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Docker CLI
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    . /etc/os-release && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
DOCKERFILE

# 5. Construir imagen personalizada
docker build -t jenkins-modulo3-custom:1.0 /opt/jenkins-custom

# 6. Crear volumen persistente
docker volume create jenkins_home

# 7. Ejecutar Jenkins con acceso al Docker Engine del host
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add "$(stat -c '%g' /var/run/docker.sock)" \
  jenkins-modulo3-custom:1.0

# 8. Mostrar estado
docker ps
