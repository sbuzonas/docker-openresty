FROM alpine:3.4
MAINTAINER Steve Buzonas <steve@fancyguy.com>

ENV DNSMASQ_VERSION=2.76-r0
ENV DUMB_INIT_VERSION=1.1.2
ENV OPENSSL_VERSION=1.0.2h-r1
ENV PYTHON_VERSION=2.7.12-r0
ENV PY_PIP_VERSION=8.1.2-r0
ENV SUPERVISOR_VERSION=3.3.0

RUN apk add --update \
    ca-certificates \
    openssl=${OPENSSL_VERSION} \
    dnsmasq=${DNSMASQ_VERSION} \
    python=${PYTHON_VERSION} \
    py-pip=${PY_PIP_VERSION} && \
    pip install --no-cache-dir supervisor==${SUPERVISOR_VERSION} && \
    wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    sed -i 's/#user=/user=root/g' /etc/dnsmasq.conf && \
    rm -rf /var/cache/apk/*

EXPOSE 80

COPY supervisord.conf /etc/supervisord.conf

CMD ["dumb-init", "supervisord" ]
