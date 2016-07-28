FROM alpine:3.4
MAINTAINER Steve Buzonas <steve@fancyguy.com>

ENV DUMB_INIT_VERSION=1.1.2

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init

