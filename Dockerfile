FROM alpine:3.4

MAINTAINER ivan@lagunovsky.com

ENV NGINX_VERSION 1.11.2
ENV PAGESPEED_VERSION 1.11.33.2
ENV SOURCE_DIR /tmp/src
ENV LIBPNG_LIB libpng12
ENV LIBPNG_VERSION 1.2.56

RUN set -x && \
    apk --no-cache --update add \
        bash \
        ca-certificates \
        libuuid \
        apr \
        apr-util \
        libjpeg-turbo \
        icu \
        icu-libs \
        openssl \
        pcre \
        zlib && \
    apk --no-cache --update add -t .build-deps \
        apache2-dev \
        apr-dev \
        apr-util-dev \
        build-base \
        icu-dev \
        libjpeg-turbo-dev \
        linux-headers \
        gperf \
        openssl-dev \
        pcre-dev \
        python \
        wget \
        zlib-dev

RUN mkdir ${SOURCE_DIR} && \
    cd ${SOURCE_DIR} && \
    wget -O- https://dl.google.com/dl/linux/mod-pagespeed/tar/beta/mod-pagespeed-beta-${PAGESPEED_VERSION}-r0.tar.bz2 | tar -jxv && \
    wget -O- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zxv && \
    wget -O- ftp://ftp.simplesystems.org/pub/libpng/png/src/${LIBPNG_LIB}/libpng-${LIBPNG_VERSION}.tar.gz | tar -zxv && \
    wget -O- https://github.com/pagespeed/ngx_pagespeed/archive/v${PAGESPEED_VERSION}-beta.tar.gz | tar -zxv && \
    cd ${SOURCE_DIR}/libpng-${LIBPNG_VERSION} && \
    ./configure --build=$CBUILD --host=$CHOST --prefix=/usr --enable-shared --with-libpng-compat && \
    make && \
    make install && \
    cd ${SOURCE_DIR} && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/automatic_makefile.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/libpng_cflags.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/pthread_nonrecursive_np.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/rename_c_symbols.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/stack_trace_posix.patch && \
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION} && \
    patch -p1 -i ${SOURCE_DIR}/automatic_makefile.patch && \
    patch -p1 -i ${SOURCE_DIR}/libpng_cflags.patch && \
    patch -p1 -i ${SOURCE_DIR}/pthread_nonrecursive_np.patch && \
    patch -p1 -i ${SOURCE_DIR}/rename_c_symbols.patch && \
    patch -p1 -i ${SOURCE_DIR}/stack_trace_posix.patch && \
    ./generate.sh -D use_system_libs=1 -D _GLIBCXX_USE_CXX11_ABI=0 -D use_system_icu=1 && \
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src && \
    make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" && \
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/ && \
    make psol BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" && \
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol && \
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 && \
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/out/Release/obj ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/net ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/testing ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/third_party ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/tools ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/pagespeed_automatic.a ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 && \
    cd ${SOURCE_DIR}/nginx-${NGINX_VERSION} && \
    LD_LIBRARY_PATH=${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/usr/lib ./configure --with-ipv6 \
        --prefix=/var/lib/nginx \
        --sbin-path=/usr/sbin \
        --modules-path=/usr/lib/nginx \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_realip_module \
        --without-http_autoindex_module \
        --without-http_browser_module \
        --without-http_geo_module \
        --without-http_memcached_module \
        --without-http_userid_module \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module \
        --without-http_split_clients_module \
        --without-http_uwsgi_module \
        --without-http_scgi_module \
        --without-http_referer_module \
        --without-http_upstream_ip_hash_module \
        --with-poll_module \
        --with-select_module \
        --with-http_addition_module \
        --with-http_geoip_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx.pid \
        --add-module=${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta \
        --with-cc-opt="-fPIC -I /usr/include/apr-1" \
        --with-ld-opt="-luuid -lapr-1 -laprutil-1 -licudata -licuuc -L${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/usr/lib -lpng12 -lturbojpeg -ljpeg" && \
   make && \
   make install

RUN apk del .build-deps && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

COPY config/ /etc/nginx/

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
