#!/usr/bin/with-contenv bash
# Is certbot working correctly ?
if ! certbot --version > /dev/null 2>&1; then echo "[ERROR] Certbot script fails, please report error !" && exit 1; fi

##
# Variables
DOMAINS="$DOMAINS"
EMAIL="$EMAIL"
LE_FOLDER="/config/ssl/letsencrypt"
MAX_DAYS_TO_EXPIRATION=30
[[ -z "$(pidof haproxy)" ]] && LE_PORT=80 || LE_PORT=9999

##
# Functions
certificate_needs_update() {
# Check the expiration date on the certificate
# true if less than speficifed MAX_DAYS.
        [ "$#" -ne 3 ] && exit 1
        cert_folder="$1"
        main_cert_name="$2"
        max_days_to_expiration="$3"
        exp_time=$(date -D "`openssl x509 -in $cert_folder/$main_cert_name/$main_cert_name.pem -text -noout | grep 'Not After' | cut -c 25-`" +%s)
        now=$(date -D "now" +%s)
        days_to_exp=$(echo \( $exp_time - $now \) / 86400 | bc)
        if [ "$days_to_exp" -gt "$max_days_to_expiration" ]; then
                return 1
        else
                echo "$days_to_exp" && return 0
        fi
}

combine_cert() {
# Output the PEM with key and cert inside.
        [ "$#" -ne 2 ] && exit 1
        cert_folder="$1"
        main_cert_name="$2"
        [ ! -f "$cert_folder/live/$main_cert_name/fullchain.pem" ] && exit 1
        mkdir -p "$cert_folder/$main_cert_name/"
        cat "$cert_folder/live/$main_cert_name/privkey.pem" "$cert_folder/live/$main_cert_name/fullchain.pem" > "$cert_folder/$main_cert_name/$main_cert_name.pem"
}

create_cert() {
# Generate the certificate
# Always renew because we check the date by ourselves
        [ "$#" -ne 3 ] && exit 1
        dns="$1"
        email="$2"
        port="$3"
        certbot certonly \
          --no-self-upgrade \
          --standalone \
          --non-interactive \
          --agree-tos \
          --renew-by-default \
          --rsa-key-size 4096 \
          --standalone-supported-challenges http-01 \
          --http-01-port "$port" \
          --email "$email" \
          -d "$dns"
}

sort_domains_list() {
# Split DOMAINS around comas in lines
# and sort each lines per dns length
# and output lines according to LetsEncrypt --domain value.
        [[ "$1" ]] || exit 1
        domains="$1"
        result=""
        dns_groups=$(echo "$domains" | sed -r 's/,\s+/\n/g' | sed -r 's/\s+/, /g')
        for sameroot in "$dns_groups"
        do
                result="$res $(echo $dns_groups | xargs -n1 | tr -d ',' | awk '{ print length($0), $0 }' | sort -n | cut -d ' ' -f 2- | tr '\n' ',' | sed -r 's/,$//g')"
        done
        echo $result
}

##
# Scripting
for dns_group in $(sort_domains_list "$DOMAINS")
do
        MAIN_CERT_NAME="$(echo $dns_group | cut -d ',' -f 1)"
        DNS_LIST="$dns_group"
        [[ ! -f "$LE_FOLDER/$MAIN_CERT_NAME/$MAIN_CERT_NAME.pem" ]] && echo "[WARN] Certificate file not found for $DNS_LIST." && INITIAL_RENEWAL=true

        if [[ $INITIAL_RENEWAL ]]
        then
                echo "[INFO] Creating certificate for $DNS_LIST"
                create_cert "$DNS_LIST" "$EMAIL" "$LE_PORT"
                combine_cert "$LE_FOLDER" "$MAIN_CERT_NAME"
                echo "[INFO] CertBot initial process finished for domains $DNS_LIST"
                echo "[INFO] Setup your SSL frontend with $LE_FOLDER/$MAIN_CERT_NAME/$MAIN_CERT_NAME.pem !"
                echo "********************************************************************"
        else
                DAYS=$(certificate_needs_update "$LE_FOLDER" "$MAIN_CERT_NAME" "$MAX_DAYS_TO_EXPIRATION")
                if [ "$?" ]
                then
                        echo "[WARN] The certificate for $DNS_LIST is about to expire soon. Starting Certbot renewal script..."
                        create_cert "$DNS_LIST" "$EMAIL" "$LE_PORT" || exit 1
                        combine_cert "$LE_FOLDER" "$MAIN_CERT_NAME"
                        echo "[INFO] Certbot renew finished for $MAIN_CERT_NAME certificates."
                        [[ $(pidof haproxy) ]] &&  s6-svc -h /var/run/s6/services/haproxy/ || s6-svc -u /var/run/s6/services/haproxy/
                else
                        echo "The certificate for $DNS_LIST is up to date, no need for renewal ($DAYS days left)."
                fi
        fi
done
