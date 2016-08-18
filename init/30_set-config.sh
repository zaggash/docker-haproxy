#!/bin/bash
CONF_FILE="haproxy.cfg-ssl"
SSL_FOLDER="/config/ssl/default"

[[ ! -f /config/haproxy.cfg ]] && cp /defaults/$CONF_FILE /config/haproxy.cfg ||  echo "Config file already exists."
mkdir -p /var/run/haproxy/ $SSL_FOLDER
chown -R abc.abc /var/run/haproxy/ /config/
