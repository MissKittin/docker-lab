#!/bin/sh

if [ ! "$(whoami)" = 'root' ] && ! groups | grep -qw 'docker'; then
	echo "No superuser"
	exit 1
fi

if ! command -v 'docker"' > /dev/null 2>&1; then
	echo 'docker is not installed'
	exit 1
fi

if [ "${2}" = '' ]; then
	echo "Usage: ${0##*/} path/to/directory image-name:tag"
	exit 1
fi

if [ ! -d "${1}" ]; then
	echo "${1} is not a directory"
	exit 1
fi

cd "${1}"
tar cpf - . | docker import - "${2}"

exit "${?}"
