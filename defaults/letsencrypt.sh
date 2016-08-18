#!/bin/bash

LE_PORT=9999
MAX_DAYS_TO_EXPIRATION=30
ROOT_DOMAIN=$(echo $DOMAINS | cut -d "," -f 1)

LE_PRIVATE_KEY_FILE="/etc/letsencrypt/live/$ROOT_DOMAIN/privkey.pem"
LE_CERTIFICATE_FILE="/etc/letsencrypt/live/$ROOT_DOMAIN/fullchain.pem"
HA_PRIVATE_KEY_FILE="/config/ssl/letsencrypt/$ROOT_DOMAIN/privkey.pem"
HA_CERTIFICATE_FILE="/config/ssl/letsencrypt/$ROOT_DOMAIN/fullchain.pem"
FULLCHAIN_FILE="/config/ssl/letsencrypt/$ROOT_DOMAIN/$ROOT_DOMAIN.pem"

[[ ! -f $HA_CERTIFICATE_FILE ]] && { echo "Certificate file not found for $DOMAINS."; INITIAL_RENEWAL=true; }
[[ -z "$(pidof haproxy)" ]] && LE_PORT=80

##
#FUNCTIONS
copy_cert() {
      mkdir -p "/config/ssl/letsencrypt/$ROOT_DOMAIN/"
      cat $LE_PRIVATE_KEY_FILE $LE_CERTIFICATE_FILE > $FULLCHAIN_FILE
      cp $LE_PRIVATE_KEY_FILE $HA_PRIVATE_KEY_FILE
      cp $LE_CERTIFICATE_FILE $HA_CERTIFICATE_FILE
      chown -R abc.abc /config/ssl/letsencrypt
}
certificate_needs_update() {
      exp_time=$(date -d "`openssl x509 -in $HA_CERTIFICATE_FILE -text -noout | grep "Not After" | cut -c 25-`" +%s)
      now=$(date -d "now" +%s)
      days_to_exp=$(echo \( $exp_time - $now \) / 86400 | bc)
      if [ "$days_to_exp" -gt "$MAX_DAYS_TO_EXPIRATION" ]; then
          return 1
      else
           return 0
      fi
}
create_cert() {
      /app/certbot-auto certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --renew-by-default \
        --rsa-key-size 4096 \
        --standalone-supported-challenges http-01 \
        --http-01-port $LE_PORT \
        --email $EMAIL \
        -d $DOMAINS
}
 ##
#Scripting
if [[ $INITIAL_RENEWAL ]]
then
      echo "Creating certificate..."
      create_cert
      copy_cert
      echo "LetsEncrypt initial process finished for domain $ROOT_DOMAIN."
      echo -e "Setup your SSL frontend with /config/ssl/letsencrypt/$ROOT_DOMAIN.pem ! \n"
else
      if certificate_needs_update
      then
              echo "The certificate for $DOMAINS is about to expire soon. Starting Let's Encrypt renewal script..."
              create_cert
              copy_cert
              echo -e "LetsEncrypt process finished for domain $ROOT_DOMAIN. \n"
              [[ `pidof haproxy` ]] && sv restart haproxy || sv start haproxy
      else
               echo -e "The certificate is up to date, no need for renewal ($days_to_exp days left). \n"
      fi
fi
