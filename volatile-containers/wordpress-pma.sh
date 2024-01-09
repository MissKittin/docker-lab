#!/bin/bash
NAME='wordpress'
PMA_PORT='9000'

[ ! "${1}" = '' ] && NAME="${1}"

if ! docker ps -a | awk '{print $NF}' | grep "^${NAME}$" > /dev/null 2>&1; then
	echo "Container ${NAME} not exists"
	exit 1
fi

while netstat --inet -n -a -p | grep ":${PMA_PORT}" > /dev/null 2>&1; do
	PMA_PORT="$((${PMA_PORT}+1))"
done

echo -n "PMA server port [${PMA_PORT}]: "
read pma_port_answer
[ "${pma_port_answer}" = "" ] || PMA_PORT="${pma_port_answer}"

docker run --rm -it \
	--name=${NAME}-pma \
	--network ${NAME} \
	-p 127.0.0.1:${PMA_PORT}:80 \
	-e PMA_HOST=${NAME}-db \
	phpmyadmin/phpmyadmin:latest

exit 0
