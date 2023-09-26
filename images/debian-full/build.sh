#!/bin/sh

cd "$(dirname "$(readlink -f "${0}")")"

if [ ! "$(whoami)" = 'root' ]; then
	echo "I don't have required power"
	exit 1
fi

if [ -e './src' ]; then
	echo 'Remove src directory first'
	exit 1
fi

if ! debootstrap --help > /dev/null 2>&1; then
	echo 'Install debootstrap first'
	exit 1
fi

if [ "${2}" = '' ]; then
	echo "${0} debian|ubuntu code-name"
	echo 'eg'
	echo "${0} debian bullseye"

	exit 1
fi

mkdir './src' || exit 1
cd './src'

case "${1}" in
	'debian')
		debootstrap --variant=minbase "${2}" . http://deb.debian.org/debian || exit 1
		echo 'debian' > ./etc/hostname
	;;
	'ubuntu')
		debootstrap --variant=minbase "${2}" . http://archive.ubuntu.com/ubuntu/ || exit 1
		echo 'ubuntu' > ./etc/hostname
	;;
	*)
		rmdir './src'

		echo 'debian or ubuntu'
		exit 1
	;;
esac

echo 'nameserver 9.9.9.9' > ./etc/resolv.conf

chroot . apt-mark auto $(chroot . apt-mark showmanual)
chroot . apt-get clean

# remove cache
rm ./var/cache/ldconfig/aux-cache

# remove backup files
rm ./var/cache/debconf/*.dat-old
rm ./var/lib/dpkg/*-old
rm ./var/lib/ucf/hashfile.*
rm ./var/lib/ucf/registry.*
for i in group- gshadow- passwd- shadow- subgid- subuid-; do
	rm ./etc/${i}
done

# remove apt lists
for i in ./var/lib/apt/lists/*; do
	[ "${i}" = './var/lib/apt/lists/*' ] && break
	if [ "${i}" = './var/lib/apt/lists/auxfiles' ] || [ "${i}" = './var/lib/apt/lists/lock' ] || [ "${i}" = './var/lib/apt/lists/partial' ]; then
		echo " i ${i}"
	else
		rm "${i}"
	fi
done

# clear mountpoints
rm -r -f ./dev/*
rm -r -f ./run/*

# remove root history
rm ./root/.bash_history

exit 0
