#!/bin/bash

HTTP_PORT='9000'

while netstat --inet -n -a -p | grep ":${HTTP_PORT}" > /dev/null 2>&1; do
	HTTP_PORT="$((${HTTP_PORT}+1))"
done

echo -n "HTTP server port [${HTTP_PORT}]: "
read http_port_answer
[ "${http_port_answer}" = "" ] || HTTP_PORT="${http_port_answer}"

docker volume create portainer_data
docker run -d \
	--name=portainer \
	-p 127.0.0.1:${HTTP_PORT}:9000 \
	-v portainer_data:/data \
	-v '/var/run/docker.sock:/var/run/docker.sock' \
	--restart unless-stopped \
	portainer/portainer

exit 0
