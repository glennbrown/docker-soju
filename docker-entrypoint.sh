#!/bin/sh

set -eux

if ! [ -r /etc/ssl/certs/soju/$(hostname -f).crt ] || ! [ -r /etc/ssl/certs/soju/$(hostname -f).key ]
then
    echo Cannot find Soju certificate and/or key. 1>&2
    ls -la /etc/ssl/certs/soju 1>&2
    exit 1
fi

if ! [ -r /etc/soju/config ]
then
    echo "No existing configuration creating a default configuration file!"
    cp /etc/soju/config.default /etc/soju/config
    echo hostname $(hostname -f) >> /etc/soju/config
fi

exec su - -c 'exec soju --config /etc/soju/config' soju