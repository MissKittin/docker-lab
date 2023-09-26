#!/bin/bash
# user: admin
# passwotd: adminadminadmin

HTTP_PORT='9000'
admin_password="\$2y\$05\$9OufNF57Jv.r6knl6ReFI.AP97ewS6VvRDr44pfpsM.VIGfFgFWDK"

while netstat --inet -n -a -p | grep ":${HTTP_PORT}" > /dev/null 2>&1; do
	HTTP_PORT="$((${HTTP_PORT}+1))"
done

echo -n "HTTP server port [${HTTP_PORT}]: "
read http_port_answer
[ "${http_port_answer}" = "" ] || HTTP_PORT="${http_port_answer}"

docker run --rm -it \
	--name=portainer \
	-p 127.0.0.1:${HTTP_PORT}:9000 \
	-v portainer_data:/data \
	-v '/var/run/docker.sock:/var/run/docker.sock' \
	portainer/portainer-ce \
	--no-analytics --admin-password="${admin_password}"

exit 0
