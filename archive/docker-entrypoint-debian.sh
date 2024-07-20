#!/bin/sh

set -eux

mkdir -p /var/lib/soju/logs /etc/ssl/certs/soju /home/soju/uploads /etc/soju /run/soju
chown -R soju:soju /home/soju/uploads /run/soju /var/lib/soju /etc/soju/config
exec su - -c 'exec soju -config /etc/soju/config' soju