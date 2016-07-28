FROM alpine:3.4
MAINTAINER Steve Buzonas <steve@fancyguy.com>

ENV PYTHON_VERSION=2.7.12-r0
ENV PY_PIP_VERSION=8.1.2-r0
ENV SUPERVISOR_VERSION=3.3.0
ENV DUMB_INIT_VERSION=1.1.2

RUN apk add --update \
    python=${PYTHON_VERSION} \
    py-pip=${PY_PIP_VERSION} && \
    php install --no-cache-dir supervisor==${SUPERVISOR_VERSION} && \
    wget -O /usr/local/bin/dumb-init
    https://github.com/Yelp/dumb-init/releases/download/${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    rm -rf /var/cache/apk/*

EXPOSE 80

COPY supervisord.conf /etc/supervisord.conf

CMD ["dumb-init", "supervisord" ]
