Based on linuxserver.io baseimage but NOT SUPPORTED by them.

# zaggash/docker-haproxy
[![](https://images.microbadger.com/badges/image/zaggash/docker-haproxy.svg)](https://microbadger.com/images/zaggash/docker-haproxy "Get your own image badge on microbadger.com")
[hub]: https://hub.docker.com/r/zaggash/docker-haproxy/

The Reliable, High Performance TCP/HTTP Load Balancer.
LetsEncrypt support.

[haproxy](http://www.haproxy.org/)

[![haproxy](https://cdn.haproxy.com/static/img/slider1small.png)]

## Usage

```
docker create --name=haproxy \
-v <path to data>:/config \
-e TZ \
-e PGID=<gid> -e PUID=<uid> \
-p 19999:19999 \
zaggash/docker-netdata
```

**Parameters**

* `-p 19999` - the port(s)
* `-v /config` - where it should store config files and logs
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` for timezone information

It is based on alpine linux with s6 overlay, for shell access whilst the container is running do `docker exec -it netdata /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

## Setting up the application 

Webui is on port 19999


## Info

* To monitor the logs of the container in realtime `docker logs -f netdata`.
