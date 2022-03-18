#!/bin/sh

case "${1}" in
	'import')
		for volume in *; do
			[ "${volume}" = '*' ] && break

			docker volume create ${volume}
			docker run --rm \
				-v $(pwd):/backup \
				-v ${volume}:/content \
				busybox \
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
		echo "${0} import|export"
		exit 1
	;;
esac

exit 0
