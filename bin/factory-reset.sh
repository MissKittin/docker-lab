#!/bin/sh
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)
docker system prune -a -f --volumes
docker rmi $(docker images -aq)
docker volume prune -f
docker network prune -f
