#!/bin/sh

set -eux

if ! [ -r /etc/ssl/certs/soju/soju.crt ] || ! [ -r /etc/ssl/certs/soju/soju.key ]
then
    echo Cannot find Soju certificate and/or key. 1>&2
    ls -la /etc/ssl/certs/soju 1>&2
    exit 1
fi

cp /etc/soju/config.no-hostname /etc/soju/config
echo hostname $(hostname --fqdn) >> /etc/soju/config
exec su - -c 'exec soju -config /etc/soju/config' soju