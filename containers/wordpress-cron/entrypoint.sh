#!/bin/sh

if [ ! -d '/etc/cron.d' ]; then
	echo ' - Initializing'

	if [ "${WP_HOST}" = '' ]; then
		echo ' - Error: no WP_HOST variable specified'
		exit 1
	fi

	if [ "${CRON_EVERY}" = '' ]; then
		echo ' - wp-cron will be run every minute'
		CRON_EVERY="*"
	else
		echo ' - wp-cron will be run every '"${CRON_EVERY}"' minutes'
		CRON_EVERY="*/${CRON_EVERY}"
	fi

	mkdir '/etc/cron.d'

	echo "${CRON_EVERY}"' * * * *	wget -O- http://'"${WP_HOST}"'/wp-cron.php' > /etc/cron.d/root
fi

if [ "${CRON_DEBUG}" = '1' ]; then
	echo ' - Debug build'

	echo ''
	cat /etc/cron.d/root

	exec crond -f -l 0 -c /etc/cron.d -L /dev/stdout
fi

exec crond -f -c /etc/cron.d -L /dev/null

