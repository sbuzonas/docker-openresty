FROM alpine:3.4
MAINTAINER Steve Buzonas <steve@fancyguy.com>

ENV DNSMASQ_VERSION=2.76-r0
ENV DUMB_INIT_VERSION=1.1.2
ENV OPENRESTY_VERSION=1.9.7.3
ENV OPENSSL_VERSION=1.0.2h-r1
ENV PYTHON_VERSION=2.7.12-r0
ENV SUPERVISOR_VERSION=3.3.0

ENV OPENRESTY_PREFIX=/opt/openresty
ENV NGINX_PREFIX=${OPENRESTY_PREFIX}/nginx
ENV VAR_PREFIX=/var/nginx

RUN apk add --update \
    ca-certificates \
    py-pip \
    openssl=${OPENSSL_VERSION} \
    dnsmasq=${DNSMASQ_VERSION} \
    python=${PYTHON_VERSION} && \
    pip install --no-cache-dir supervisor==${SUPERVISOR_VERSION} && \
    wget -qO /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    sed -i 's/#user=/user=root/g' /etc/dnsmasq.conf && \
    apk del py-pip && \
    rm -rf /var/cache/apk/*

RUN apk add --update --virtual build-deps \
    gcc \
    make \
    musl-dev \
    ncurses-dev \
    openssl-dev \
    pcre-dev \
    perl \
    readline-dev \
    zlib-dev && \
    apk add --update \
    libgcc \
    libpcre16 \
    libpcre32 \
    libpcrecpp \
    libstdc++ \
    pcre && \
    readonly BUILD_DIR=$(mktemp -d) && \
    cd ${BUILD_DIR} && \
    echo "==> Downloading OpenResty..." && \
    wget -qO - http://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz | tar -xvz && \
    cd openresty-* && \
    echo "==> Configuring OpenResty..." && \
    readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    echo "using upto $NPROC threads" && \
    ./configure \
    --prefix=${OPENRESTY_PREFIX} \
    --http-client-body-temp-path=${VAR_PREFIX}/client_body_temp \
    --http-proxy-temp-path=${VAR_PREFIX}/proxy_temp \
    --http-log-path=${VAR_PREFIX}/access.log \
    --error-log-path=${VAR_PREFIX}/error.log \
    --pid-path=${VAR_PREFIX}/nginx.pid \
    --lock-path=${VAR_PREFIX}/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    -j${NPROC} && \
    echo "==> Building OpenResty..." && \
    make -j${NPROC} && \
    echo "==> Installing OpenResty..." && \
    make install && \
    ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/sbin/nginx && \
    ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/local/sbin/openresty && \
    ln -sf ${OPENRESTY_PREFIX}/bin/resty /usr/local/bin/resty && \
    ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* ${OPENRESTU_PREFIX}/luajit/bin/lua && \
    ln -sf ${OPENRESTY_PREFIX}/luajit/bin/luajit-* /usr/local/bin/lua && \
    echo "==> Cleaning up..." && \
    cd / && \
    rm -rf ${BUILD_DIR} && \
    apk del build-deps && \
    rm -rf /var/cache/apk/*

EXPOSE 80 443
WORKDIR $NGINX_PREFIX/

COPY supervisord.conf /etc/supervisord.conf

CMD ["dumb-init", "supervisord" ]
