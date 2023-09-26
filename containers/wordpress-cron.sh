#!/bin/sh
NAME='wordpress'

[ ! "${1}" = '' ] && NAME="${1}"

if ! docker ps -a | awk '{print $NF}' | grep "^${NAME}$" > /dev/null 2>&1; then
	echo "Container ${NAME} not exists"
	echo -n 'Continue? (y/N} '
	read answer
	[ "${answer}" = 'y' ] || exit 1
fi

if [ "${2}" = 'debug' ]; then
	docker run -d \
		--name=${NAME}-cron \
		--network ${NAME} \
		-e WP_HOST=${NAME} \
		-e CRON_EVERY=10 \
		-e CRON_DEBUG=1 \
		--restart unless-stopped \
		wordpress-cron
else
	docker run -d \
		--name=${NAME}-cron \
		--network ${NAME} \
		-e WP_HOST=${NAME} \
		-e CRON_EVERY=10 \
		--restart unless-stopped \
		wordpress-cron
fi

docker exec ${NAME} cat /var/www/html/wp-config.php | grep "define('DISABLE_WP_CRON', true);" > /dev/null 2>&1 || \
	docker exec ${NAME} sed -i "/\* That.s all, stop editing! Happy publishing. \*\// i\define('DISABLE_WP_CRON', true);" /var/www/html/wp-config.php

exit 0
