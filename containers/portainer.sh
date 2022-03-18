#!/bin/sh
# user: admin
# pass: adminadmin

docker volume create portainer_data
docker run -d \
	--name=portainer \
	-p 127.0.0.1:9000:9000 \
	-v portainer_data:/data \
	-v '/var/run/docker.sock:/var/run/docker.sock' \
	--restart unless-stopped \
	portainer/portainer

exit 0
