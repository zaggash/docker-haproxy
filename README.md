Based on linuxserver.io baseimage but NOT SUPPORTED by them.

# zaggash/docker-haproxy
[![](https://images.microbadger.com/badges/image/zaggash/docker-haproxy.svg)](https://microbadger.com/images/zaggash/docker-haproxy "Get your own image badge on microbadger.com")
[hub]: https://hub.docker.com/r/zaggash/docker-haproxy/

The Reliable, High Performance TCP/HTTP Load Balancer. [haproxy](http://www.haproxy.org/)
This container have LetsEncrypt support for multiple domain.

![haproxy](https://cdn.haproxy.com/static/img/slider1small.png)

## Usage

```
docker create --name=haproxy \
-v <path to data>:/config \
-e TZ \
-e PGID=<gid> -e PUID=<uid> \
-e DOMAINS=<domain.name...> \
-e EMAIL=<email>
-p 80:80 \
-p 443:443 \
zaggash/docker-haproxy
```

**Parameters**

* `-p 80`
* `-p 443` - the port(s)
* `-v /config` - where it should store config files and logs
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` for timezone information
* `-e DOMAINS` - domain to ask for a certificate, see below for more information
* `-e EMAIL` - your email for the letsencrypt account

It is based on alpine linux with s6 overlay, for shell access whilst the container is running do `docker exec -it haproxy /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

## Setting up the application 

You can edit the config in /config/haproxy.cfg
There is default configuration which is working with an default auto-generated certificate.

In order to generate letsencrypt certificate, follow the rules :

Each domain seperated by a coma (,) will be have its own certificate.
If you add multiple domain sperated by a space between the coma (,) all these domains will be on a single certificate, the certificate name will be the shortest domain name of the group

DOMAINS="blah.domain.fr domains.fr, www.dom.com, blahblah.domdom.net www.domdom.net"

 * blah.domain.fr and domains.fr will be in the same certificate named domains.fr
 * www.dom.com will have his own certificate named www.dom.com
 * blahblah.domdom.net and www.domdom.net  will be in the same certificate named  www.domdom.net.pem


## Info

* To monitor the logs of the container in realtime `docker logs -f haproxy`.
