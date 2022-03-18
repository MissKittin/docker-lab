#!/bin/sh
NAME='wordpress'
PMA_PORT='9002'

[ ! "${1}" = '' ] && NAME="${1}"

salts="$(wget -O- 'https://api.wordpress.org/secret-key/1.1/salt/')" || exit 1
salts="$(echo "${salts}" | sed -e "s/.*'\(.*\)'.*/\1/")"
AUTH_KEY=$(echo "${salts}" | sed -n 1p)
SECURE_AUTH_KEY=$(echo "${salts}" | sed -n 2p)
LOGGED_IN_KEY=$(echo "${salts}" | sed -n 3p)
NONCE_KEY=$(echo "${salts}" | sed -n 4p)
AUTH_SALT=$(echo "${salts}" | sed -n 5p)
SECURE_AUTH_SALT=$(echo "${salts}" | sed -n 6p)
LOGGED_IN_SALT=$(echo "${salts}" | sed -n 7p)
NONCE_SALT=$(echo "${salts}" | sed -n 8p)

docker network create --driver bridge ${NAME}

docker volume create ${NAME}-db_data
docker run -d \
	--name=${NAME}-db \
	--network ${NAME} \
	-v ${NAME}-db_data:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=mysqlroot \
	-e MYSQL_DATABASE=wordpress \
	-e MYSQL_USER=wordpress \
	-e MYSQL_PASSWORD=wordpress \
	--restart unless-stopped \
	mysql:5.7

docker volume create ${NAME}_data
docker run -d \
	--name=${NAME} \
	--network ${NAME} \
	-v ${NAME}_data:/var/www/html \
	-e WORDPRESS_DB_HOST=${NAME}-db \
	-e WORDPRESS_DB_USER=wordpress \
	-e WORDPRESS_DB_PASSWORD=wordpress \
	-e WORDPRESS_DB_NAME=wordpress \
	-e WORDPRESS_AUTH_KEY="${AUTH_KEY}" \
	-e WORDPRESS_SECURE_AUTH_KEY="${SECURE_AUTH_KEY}" \
	-e WORDPRESS_LOGGED_IN_KEY="${LOGGED_IN_KEY}" \
	-e WORDPRESS_NONCE_KEY="${NONCE_KEY}" \
	-e WORDPRESS_AUTH_SALT="${AUTH_SALT}" \
	-e WORDPRESS_SECURE_AUTH_SALT="${SECURE_AUTH_SALT}" \
	-e WORDPRESS_LOGGED_IN_SALT="${LOGGED_IN_SALT}" \
	-e WORDPRESS_NONCE_SALT="${NONCE_SALT}" \
	--restart unless-stopped \
	wordpress:latest

docker run -d \
	--name=${NAME}-pma \
	--network ${NAME} \
	-p 127.0.0.1:${PMA_PORT}:80 \
	-e PMA_HOST=${NAME}-db \
	--restart unless-stopped \
	phpmyadmin/phpmyadmin:latest

docker network connect ${NAME} nginx-proxy-manager
docker restart nginx-proxy-manager

exit 0
