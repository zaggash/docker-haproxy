#!/bin/bash
SUBJECT="//C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
if [[ -f /config/ssl/default/cert.key && -f /config/ssl/default/cert.crt && -f /config/ssl/default/cert.pem ]]; then
  echo "Keys can be found in /config/ssl/default"
else
  echo "Generating self-signed keys in /config/ssl/default, you can set your own in /config/ssl"
  /sbin/setuser abc openssl req -new -x509 -days 3650 -nodes -out /config/ssl/default/cert.crt -keyout /config/ssl/default/cert.key -subj "$SUBJECT"
  /sbin/setuser abc cat /config/ssl/default/cert.crt /config/ssl/default/cert.key > /config/ssl/default/cert.pem
fi
