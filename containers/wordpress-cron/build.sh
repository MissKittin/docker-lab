#!/bin/sh
cd "${0%/*}"
docker build -t wordpress-cron .
exit 0
