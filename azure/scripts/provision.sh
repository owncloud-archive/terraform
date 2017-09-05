#!/usr/bin/env bash
set -eo pipefail

if [[ $# -ne 4 ]]; then
    echo "Usage: ${0} SERVER_ADMIN ADMIN_USERNAME ADMIN_PASSWORD OWNCLOUD_DOMAIN"
fi

SERVER_ADMIN=${1}
ADMIN_USERNAME=${2}
ADMIN_PASSWORD=${3}
OWNCLOUD_DOMAIN=${4}

sudo apt update -y

sudo apt install -y \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

sudo apt update -y

sudo apt install -y \
    docker-ce

sudo systemctl enable docker
sudo systemctl start docker

sudo gpasswd -a ${SERVER_ADMIN} docker

sudo curl --create-dirs \
    -sLo /usr/local/bin/docker-compose \
    https://github.com/docker/compose/releases/download/1.14.0/docker-compose-Linux-x86_64

echo "54a6e8550da5579b6a0b95774b3159fe9588bb538e9d858e5caf6e8e70bd3348 /usr/local/bin/docker-compose" | sha256sum -c -

sudo chmod +x /usr/local/bin/docker-compose

cat << EOF >| /home/${SERVER_ADMIN}/docker-compose.yml
version: "3"

networks:
  traefik:
    driver: bridge
  internal:
    external: false

volumes:
  server:
    driver: local
  mysql:
    driver: local
  backup:
    driver: local
  redis:
    driver: local

services:
  server:
    image: owncloud/server:10.0.2
    restart: always
    environment:
      - OWNCLOUD_DOMAIN=${OWNCLOUD_DOMAIN}
      - OWNCLOUD_DB_TYPE=mysql
      - OWNCLOUD_DB_NAME=owncloud
      - OWNCLOUD_DB_USERNAME=owncloud
      - OWNCLOUD_DB_PASSWORD=owncloud
      - OWNCLOUD_DB_HOST=db
      - OWNCLOUD_ADMIN_USERNAME=${ADMIN_USERNAME}
      - OWNCLOUD_ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - OWNCLOUD_REDIS_ENABLED=true
      - OWNCLOUD_REDIS_HOST=redis
    networks:
      - traefik
      - internal
    labels:
      - traefik.docker.network=owncloud_traefik
      - traefik.port=80
      - traefik.frontend.rule=Host:${OWNCLOUD_DOMAIN}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/index.php"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
      - server:/mnt/data
    depends_on:
      - proxy
      - db
      - redis

  db:
    image: webhippie/mariadb:latest
    restart: always
    environment:
      - MARIADB_ROOT_PASSWORD=owncloud
      - MARIADB_USERNAME=owncloud
      - MARIADB_PASSWORD=owncloud
      - MARIADB_DATABASE=owncloud
      - MARIADB_MAX_ALLOWED_PACKET=128M
      - MARIADB_INNODB_LOG_FILE_SIZE=64M
    networks:
      - internal
    labels:
      - traefik.enable=false
    healthcheck:
      test: ["CMD", "/usr/bin/healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - mysql:/var/lib/mysql
      - backup:/var/lib/backup

  redis:
    image: webhippie/redis:latest
    restart: always
    environment:
      - REDIS_MAXCONN=10000
    networks:
      - internal
    labels:
      - traefik.enable=false
    healthcheck:
      test: ["CMD", "/usr/bin/healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - redis:/var/lib/redis

  proxy:
    image: containous/traefik:v1.3.7
    restart: always
    command: --web --docker --docker.domain=docker.localhost --logLevel=DEBUG
    ports:
      - 80:80
      - 443:443
      - 8080:8080
    networks:
      - traefik
    labels:
      - traefik.enable=false
    healthcheck:
      test: ["NONE"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
      - /var/run/docker.sock:/var/run/docker.sock
EOF

docker-compose up -d
