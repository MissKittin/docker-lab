#!/bin/sh

if [ ! "$(whoami)" = 'root' ] && ! groups | grep -qw 'docker'; then
	echo 'No superuser'
	exit 1
fi

if ! command -v 'docker"' > /dev/null 2>&1; then
	echo 'docker is not installed'
	exit 1
fi

docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)
docker system prune -a -f --volumes
docker rmi $(docker images -aq)
docker volume prune -f
docker network prune -f

exit 0
