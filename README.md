# 🏂 Lightweight Docker Image include Nginx with PageSpeed module
 [![Build Status](https://travis-ci.org/lagun4ik/docker-nginx-pagespeed.svg)](https://travis-ci.org/lagun4ik/docker-nginx-pagespeed)

This PHP docker image based on [Alpine](https://hub.docker.com/_/alpine/). Alpine is based on [Alpine Linux](http://www.alpinelinux.org), lightweight Linux distribution based on [BusyBox](https://hub.docker.com/_/busybox/). The size of the image is very small.

### PageSpeed
The [PageSpeed](https://developers.google.com/speed/pagespeed/) tools analyze and optimize your site following web best practices.

### Getting The Image

This image is published in the [Docker Hub](https://hub.docker.com/r/lagun4ik/nginx-pagespeed/) as `lagun4ik/nginx-pagespeed`

### Configuration

The config is set using environments
```docker
#default values
PAGESPEED_ENABLE=on # || off
```

### Example compose file

```yaml
version: '2'

services:
  nginx:
    image: lagun4ik/nginx-pagespeed
    restart: always
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./sites-enabled:/etc/nginx/sites-enabled
      - ./www/:/var/www/
      - ./cache/ngx_pagespeed:/var/cache/ngx_pagespeed
```
