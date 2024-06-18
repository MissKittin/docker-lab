#!/bin/sh

if [ ! "$(whoami)" = 'root' ] && ! groups | grep -qw 'docker'; then
	echo 'No superuser'
	exit 1
fi

if ! command -v 'docker"' > /dev/null 2>&1; then
	echo 'docker is not installed'
	exit 1
fi

if [ ! "${2}" = '' ]; then
	cd "${2}" || exit 1
fi

case "${1}" in
	'import')
		for volume in *; do
			[ "${volume}" = '*' ] && break

			docker volume create ${volume}
			docker run --rm \
				-v $(pwd):/backup \
				-v ${volume}:/content \
				busybox:stable-uclibc \
				tar xvf /backup/${volume}
		done
	;;
	'export')
		for volume in $(docker volume ls -q); do
			docker run --rm \
				-v $(pwd):/backup \
				-v ${volume}:/content \
				busybox:stable-uclibc \
				tar cvf /backup/${volume} /content
		done
	;;
	*)
		echo "${0} import|export [path/to/directory]"
		exit 1
	;;
esac

exit 0
