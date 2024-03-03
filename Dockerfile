#
# Dockerfile for qBittorrent CLI
#

FROM alpine as source

ARG URL=https://api.github.com/repos/fedarovich/qbittorrent-cli/releases/latest

WORKDIR /root

RUN set -ex \
    && if [ "$(uname -m)" == aarch64 ]; then \
           export PLATFORM='alpine-arm64'; \
       elif [ "$(uname -m)" == x86_64 ]; then \
           export PLATFORM='alpine-x64'; \
       fi \
    && apk add --update --no-cache curl \
    && wget -O qbt-cli.tar.gz $(curl -s $URL | grep browser_download_url | egrep -o 'http.+\.tar.gz' | grep -i "$PLATFORM") \
    && mkdir /usr/local/lib/qbt-cli \
    && tar -zxf qbt-cli.tar.gz -C /usr/local/lib/qbt-cli \
    && chmod a+x /usr/local/lib/qbt-cli/qbt

FROM alpine:edge
COPY --from=source /usr/local/lib/qbt-cli /usr/local/lib/qbt-cli
RUN ln -sf /usr/local/lib/qbt-cli/qbt /usr/local/bin/qbt

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN set -ex \
    && apk --update add --no-cache \
       ca-certificates \
       icu-libs \
       krb5-libs \
       libgcc \
       libintl \
       libssl1.1@testing \
       libstdc++ \
       zlib \
    && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /root

CMD ["qbt","--help"]
