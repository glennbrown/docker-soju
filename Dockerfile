FROM alpine:3.20

ENV SOJU_VERSION=v0.8.1

RUN set -ex \
    && addgroup -g 1000 -S soju \
    && adduser -S -D -u 1000 -G soju -s /bin/sh -h /var/lib/soju soju \
    && addgroup soju users \
    && apk add --no-cache --virtual build-dependencies \
        build-base \
        git \
        sqlite-dev \
        sqlite \
        scdoc \
        go \
    && apk add --no-cache --virtual runtime-dependencies \
        sqlite-libs \
        su-exec \
        tini \
    && mkdir /soju-src \
    && git clone https://codeberg.org/emersion/soju /soju-src \
    && cd /soju-src \
    && git checkout ${SOJU_VERSION} \
    && go build \
    -buildmode=pie -modcacherw -buildvcs=false \
    -trimpath -tags=libsqlite \
    -ldflags "-X 'codeberg.org/emersion/soju/config.DefaultPath=/etc/soju/config' \
    -X 'codeberg.org/emersion/soju/config.DefaultUnixAdminPath=/run/soju/admin'" \
    -o . ./cmd/soju ./cmd/sojudb ./cmd/sojuctl \
    && cp soju sojuctl sojudb /usr/bin \
    && mkdir -p /var/lib/soju/logs /etc/ssl/certs/soju /home/soju/uploads /etc/soju /run/soju \
    && chown -R soju:soju /etc/ssl/certs/soju /home/soju/uploads /run/soju \
    && apk del build-dependencies \
    && cd / && rm -rf /soju-src \
    && cd /root && rm -rf go .cache

VOLUME /var/lib/soju
VOLUME /etc/soju
VOLUME /home/soju/uploads

COPY --chmod=0755 docker-entrypoint.sh /docker-entrypoint.sh
COPY --chown=soju:soju config /etc/soju/config.default

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["soju", "--config", "/etc/soju/config"]