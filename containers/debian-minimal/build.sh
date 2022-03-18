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

echo 'Apt::AutoRemove::SuggestsImportant "false";' > ./etc/apt/apt.conf.d/99-tweaks
echo 'Acquire::Languages "none";' >> ./etc/apt/apt.conf.d/99-tweaks
echo 'APT::Install-Recommends "false";' >> ./etc/apt/apt.conf.d/99-tweaks
echo 'Apt::AutoRemove::RecommendsImportant "false";' >> ./etc/apt/apt.conf.d/99-tweaks

echo 'path-exclude /usr/share/bash-completion/completions/*' > ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/doc/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-include /usr/share/doc/*/copyright' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/man/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/groff/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/info/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/lintian/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/linda/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/include/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/locale/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks
echo 'path-exclude /usr/share/pixmaps/*' >> ./etc/dpkg/dpkg.cfg.d/01_tweaks

chroot . apt-mark auto $(chroot . apt-mark showmanual)

# remove packages
chroot . apt-get purge -y --allow-remove-essential e2fsprogs tzdata
chroot . apt-get autoremove --purge -y
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

# remove docs except copyrights
find ./usr/share/doc -depth -type f ! -name copyright | xargs rm
for i in 1 2 3 4 5 6 7 8 9 10; do
	find ./usr/share/doc -empty | xargs rmdir
done
rm -rf ./usr/share/man/* ./usr/share/groff/* ./usr/share/info/* ./usr/share/lintian/* ./usr/share/linda/* ./var/cache/man/*

# remove translations
find ./usr/share/locale -mindepth 1 -maxdepth 1 | xargs rm -r

# remove bash completions
rm ./usr/share/bash-completion/completions/*

# remove python bytecodes
find ./usr/share/python -type f -name *.pyc | xargs rm

# remove pixmaps
find ./usr/share/pixmaps -type f -or -type l | xargs rm

# remove C headers
#rm -r -f ./usr/includes/*

# purge fdisk
for i in $(ls ./sbin/*fdisk | xargs) ./usr/share/doc/fdisk/copyright; do
	[ -e "${i}" ] && echo -n '' > ${i}
done

# purge startpar
#echo -n '' > ./lib/startpar/startpar
#echo -n '' > ./usr/share/doc/startpar/copyright

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
