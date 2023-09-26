#!/bin/sh

if [ "${1}" = '' ]; then
	echo "Usage: ${0##*/} php-version"
	exit 1
fi

exec docker run --rm -it \
	-v $(pwd):/host \
	php:${1}-cli-alpine sh
