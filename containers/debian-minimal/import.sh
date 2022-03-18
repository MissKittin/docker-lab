#!/bin/sh

cd "$(dirname "$(readlink -f "${0}")")"

if [ ! "$(whoami)" = 'root' ]; then
	echo "I don't have required power"
	exit 1
fi

if [ ! -e './src' ]; then
	echo 'Run build.sh first'
	exit 1
fi

if [ "${2}" = '' ]; then
	echo "${0} debian|ubuntu code-name"
	echo 'eg'
	echo "${0} debian bullseye"

	exit 1
fi

case "${1}" in
	'debian'|'ubuntu')
		distro="${1}"
	;;
	*)
		echo 'debian or ubuntu'
		exit 1
	;;
esac

cd "./src"
tar cpf - . | docker import - ${distro}-minimal:${2}

exit 0
