FROM --platform=linux/arm64/v8 golang:alpine AS builder

ARG SOJU_VERSION=v0.8.1

RUN set -ex; \
    apk add --no-cache git gcc g++ sqlite sqlite-libs sqlite-dev make musl-dev scdoc; \
    mkdir /go/build; \
    git clone https://codeberg.org/emersion/soju /go/build/src; \
    cd /go/build/src; \
    git checkout ${SOJU_VERSION}; \
    GOOS=linux GOARCH=arm64 go build \
    -trimpath -tags=libsqlite \
    -ldflags "-X 'codeberg.org/emersion/soju/config.DefaultPath=/etc/soju/config' \
    -X 'codeberg.org/emersion/soju/config.DefaultUnixAdminPath=/run/soju/admin' \
    -linkmode external -extldflags -static" \
    -o . ./cmd/soju ./cmd/sojudb ./cmd/sojuctl

FROM --platform=linux/arm64/v8 alpine:latest

RUN set -ex; \
    apk add --no-cache su-exec tini; \
    addgroup -g 1000 -S soju; \
    adduser -S -D -u 1000 -G soju -s /bin/sh -h /var/lib/soju soju; \
    addgroup soju users; \
    mkdir -p /var/lib/soju/logs /etc/ssl/certs/soju /home/soju/uploads /etc/soju /run/soju; \
    chown -R soju:soju /etc/ssl/certs/soju /home/soju/uploads /run/soju

VOLUME /var/lib/soju
VOLUME /etc/soju
VOLUME /home/soju/uploads

COPY --from=builder --chmod=0755 /go/build/src/soju* /usr/bin
COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=soju:soju config /etc/soju/config.default

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["soju", "--config", "/etc/soju/config"]