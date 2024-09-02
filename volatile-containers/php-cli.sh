#!/bin/sh

if [ ! "$(whoami)" = 'root' ] && ! groups | grep -qw 'docker'; then
	sudo "${0}" "${1}" "${2}"
	exit "${?}"
fi

if [ "${1}" = '' ] || [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
	echo 'Binds the current directory'
	echo 'and launches a shell in the docker container'
	echo ''
	echo "Usage: ${0##*/} php-version [distro]"
	echo "eg: ${0##*/} 7.4"
	echo "eg: ${0##*/} 7.4 bullseye"
	echo 'note: default distro is alpine'
	exit 1
fi

### build-dev-env.sh patch here ###

distro='alpine'
[ ! "${2}" = '' ] && distro="${2}"

echo "Bound $(pwd) to /host"

exec docker run --rm -it \
	-v "$(pwd):/host" \
	"php:${1}-cli-${distro}" \
	sh
