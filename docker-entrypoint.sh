#!/bin/sh

if ! [ -r /etc/ssl/certs/soju/soju.crt ] || ! [ -r /etc/ssl/certs/soju/soju.key ]
then
    echo Cannot find Soju certificate and/or key. 1>&2
    ls -la /etc/ssl/certs/soju 1>&2
    exit 1
fi

if [ "$1" = 'soju' -a "$(id -u)" = '0' ]; then
    cp /etc/soju/config.default /etc/soju/config
    echo -e "\nhostname $(hostname -f)" >> /etc/soju/config
    exec su-exec soju "$@"
fi