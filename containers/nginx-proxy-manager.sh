#!/bin/sh
# Initial login: admin@example.com
# Initial password: changeme
# Login: admin@admin.com
# Password: adminadmin

ADMIN_PORT='9001'

docker volume create nginx-proxy-manager_data
docker run -d \
	--name=nginx-proxy-manager \
	-p 80:8080 \
	-p 443:4443 \
	-p 127.0.0.1:${ADMIN_PORT}:8181 \
	-v nginx-proxy-manager_data:/config \
	-e KEEP_APP_RUNNING=1 \
	-e CLEAN_TMP_DIR=1 \
	-e TZ=Europe/Warsaw \
	--restart unless-stopped \
	jlesage/nginx-proxy-manager

docker network disconnect bridge nginx-proxy-manager

exit 0
