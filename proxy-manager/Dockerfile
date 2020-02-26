ARG BUILD_FROM=hassioaddons/base:7.0.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base=0.5-r1 \
        git=2.24.1-r0 \
        npm=12.15.0-r1 \
        patch=2.7.6-r6 \
        python2=2.7.16-r3 \
        yarn=1.19.2-r0 \
    \
    && apk add --no-cache \
        apache2-utils=2.4.41-r0 \
        certbot=1.0.0-r0 \
        mariadb-client=10.4.12-r0 \
        mariadb=10.4.12-r0 \
        nginx-mod-stream=1.16.1-r6 \
        nginx=1.16.1-r6 \
        nodejs=12.15.0-r1 \
        openssl=1.1.1d-r3 \
        libcap=2.27-r0 \
    \
    && yarn global add modclean \
    \
    && curl -J -L -o /tmp/nginxproxymanager.tar.gz \
        "https://github.com/jc21/nginx-proxy-manager/archive/v2.1.1.tar.gz" \
    && mkdir /app \
    && tar zxvf \
        /tmp/nginxproxymanager.tar.gz \
        --strip 1 -C /app \
    \
    && sed -i "s#canShow('streams')#false#g" \
        /app/frontend/js/app/ui/menu/main.ejs \
    && sed -i "s#canShow('streams')#false#g" \
        /app/frontend/js/app/dashboard/main.ejs \
    && sed -i "s#, 'streams',#,#g" \
        /app/frontend/js/app/user/permissions.ejs \
    \ 
    && /bin/true

RUN /bin/true \
    && cd /app/frontend \
    && yarn install \
    && yarn build \
    #&& npm run-script build \
    && rm -rf node_modules \
    #&& yarn install --production \
    && ls -alh \
    \
    && mkdir -p /opt/nginx-proxy-manager/frontend \
    && cp -r /app/frontend/dist/. /opt/nginx-proxy-manager/frontend/ \
    #&& cp -r /app/knexfile.js /opt/nginx-proxy-manager/ \
    #&& cp -r /app/node_modules /opt/nginx-proxy-manager/ \
    #&& cp -r /app/package.json /opt/nginx-proxy-manager/ \
    #&& cp -r /app/src/backend /opt/nginx-proxy-manager/src/ \
    && /bin/true
RUN /bin/true \
    && cd /app/backend \
    && yarn install \
    && yarn eslint . \
    && rm -rf node_modules \
    && ls -alh \
    && cp -r /app/backend/. /opt/nginx-proxy-manager/

RUN cd /opt/nginx-proxy-manager \
    && yarn install \
    && rm -rf /etc/services.d/frontend \
    && rm -f /etc/nginx/conf.d/dev.conf \
    && rm -rf /opt/nginx-proxy-manager/config \
    && sed -i "s#table.string('id').notNull().primary();#table.string('id', 32).notNull().primary();#" \
        migrations/20190227065017_settings.js

RUN /bin/true \
    \
    && rm -f -r /etc/nginx \
    && cp -r /app/docker/rootfs/etc/nginx /etc/nginx \
    && rm -f /etc/nginx/conf.d/dev.conf \
    && sed -i "s#root /app/frontend;#root /opt/nginx-proxy-manager/frontend;#" \
        /etc/nginx/conf.d/production.conf \
    \
    && mkdir -p \
        /run/mysqld \
        /run/nginx \
    \
    && modclean \
        --path /opt/nginx-proxy-manager \
        --no-progress \
        --keep-empty \
        --run \
    \
    && yarn global remove modclean \
    && yarn cache clean \
    \
    && apk del --purge .build-dependencies \
    \
    && rm -f -r \
        /app \
        /etc/init.d/nginx \
        /etc/logrotate.d/nginx \
        /opt/nginx-proxy-manager/node_modules/bcrypt/build \
        /root/.node-gyp \
        /tmp/.[!.]* \
        /tmp/* \
        /usr/lib/node_modules \
        /usr/local/share/.cache \
        /var/lib/mysql \
        /var/lib/nginx \
        /var/log/nginx \
        /var/tmp/nginx \
        /var/www

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Nginx Proxy Manager" \
    io.hass.description="Manage Nginx proxy hosts with a simple, powerful interface." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.label-schema.description="Manage Nginx proxy hosts with a simple, powerful interface" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Nginx Proxy Manager" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://community.home-assistant.io/t/community-hass-io-add-on-nginx-proxy-manager/111830?u=frenck" \
    org.label-schema.usage="https://github.com/hassio-addons/addon-nginx-proxy-manager/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/hassio-addons/addon-nginx-proxy-manager" \
    org.label-schema.vendor="Community Hass.io Add-ons"
