#!/bin/bash
[[ -z "$DOMAINS" ]] && { echo "You have not set a DOMAINS environmental variable."; BYPASS=true; }
[[ -z "$EMAIL" ]] && { echo "You have not set an EMAIL environmental variable."; BYPASS=true; }

if [[ $BYPASS ]]; then
  echo "Skipping Certbot/Let's Encrypt..."
else
  #Install/Update
  [[ ! -x /app/certbot-auto ]] && {  curl -sL -o /app/certbot-auto https://dl.eff.org/certbot-auto && chmod +x /app/certbot-auto; }
  
  #Copy and exec
  [[ ! -x /app/letsencrypt.sh ]] && { cp /defaults/letsencrypt.sh /app/letsencrypt.sh && chmod +x /app/letsencrypt.sh; }
  [[ ! -f /etc/cron.d/letsencrypt ]] && cp /defaults/letsencrypt.cron /etc/cron.d/letsencrypt
  
  exec /app/letsencrypt.sh

fi
