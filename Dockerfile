FROM lsiobase/alpine
MAINTAINER zaggash

ENV DOMAINS=""
ENV EMAIL=""

RUN \
  apk add --no-cache \
    openssl \
    bc \
    certbot \
    inotify-tools && \

  apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main \
    haproxy && \

# cleanup
  rm -rf /var/cache/apk/* /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
