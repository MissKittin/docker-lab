#!/bin/sh
NAME='joomla'
PMA_PORT='9003'

[ ! "${1}" = '' ] && NAME="${1}"

docker network create --driver bridge ${NAME}

docker volume create ${NAME}-db_data
docker run -d \
	--name=${NAME}-db \
	--network ${NAME} \
	-v ${NAME}-db_data:/var/lib/mysql \
	-e MYSQL_ROOT_PASSWORD=mysqlroot \
	-e MYSQL_DATABASE=joomla \
	-e MYSQL_USER=joomla \
	-e MYSQL_PASSWORD=joomla \
	--restart unless-stopped \
	mysql:5.7

docker volume create ${NAME}_data
docker run -d \
	--name=${NAME} \
	--network ${NAME} \
	-v ${NAME}_data:/var/www/html \
	-e JOOMLA_DB_HOST=${NAME}-db \
	-e JOOMLA_DB_USER=joomla \
	-e JOOMLA_DB_PASSWORD=joomla \
	-e JOOMLA_DB_NAME=joomla \
	--restart unless-stopped \
	joomla

docker run -d \
	--name=${NAME}-pma \
	--network ${NAME} \
	-p 127.0.0.1:${PMA_PORT}:80 \
	-e PMA_HOST=${NAME}-db \
	--restart unless-stopped \
	phpmyadmin/phpmyadmin:latest

docker volume create ${NAME}-redis_data
docker run -d \
	--name=${NAME}-redis \
	--network ${NAME} \
	-v ${NAME}-redis_data:/data \
	--restart unless-stopped \
	redis

docker network connect ${NAME} nginx-proxy-manager
docker restart nginx-proxy-manager

exit 0
