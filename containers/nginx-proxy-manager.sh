#!/bin/bash
# Initial login: admin@example.com
# Initial password: changeme

TIMEZONE='Europe/Warsaw'
HTTP_PORT='80'
HTTPS_PORT='443'
ADMIN_PORT='9000'

while netstat --inet -n -a -p | grep ":${ADMIN_PORT}" > /dev/null 2>&1; do
	ADMIN_PORT="$((${ADMIN_PORT}+1))"
done

echo -n "HTTP server port [${HTTP_PORT}]: "
read http_port_answer
[ "${http_port_answer}" = "" ] || HTTP_PORT="${http_port_answer}"

echo -n "HTTPS server port [${HTTPS_PORT}]: "
read http_port_answer
[ "${http_port_answer}" = "" ] || HTTPS_PORT="${http_port_answer}"

echo -n "Admin panel server port [${ADMIN_PORT}]: "
read http_port_answer
[ "${http_port_answer}" = "" ] || ADMIN_PORT="${http_port_answer}"

docker volume create nginx-proxy-manager_data
docker run -d \
	--name=nginx-proxy-manager \
	-p ${HTTP_PORT}:8080 \
	-p ${HTTPS_PORT}:4443 \
	-p 127.0.0.1:${ADMIN_PORT}:8181 \
	-v nginx-proxy-manager_data:/config \
	-e KEEP_APP_RUNNING=1 \
	-e CLEAN_TMP_DIR=1 \
	-e TZ=${TIMEZONE} \
	--restart unless-stopped \
	jlesage/nginx-proxy-manager

docker network disconnect bridge nginx-proxy-manager

exit 0
