ARG ALPINE_VERSION=3.24
FROM alpine:${ALPINE_VERSION}

# nginx a moduly z balicku Alpine, ne kompilace ze zdrojaku: jen tak je trivy
# vidi jako apk balicky a porovnava s Alpine secdb (nginx zkompilovany do
# /usr/sbin byl pro CVE sken neviditelny - nginx2root, 11/2026).
RUN apk upgrade --no-cache \
    && apk add --no-cache \
        nginx \
        nginx-mod-http-lua \
        nginx-mod-http-lua-upstream \
        lua-resty-http \
        lua-resty-openssl \
        lua5.1-cjson \
        curl \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /etc/nginx/conf.d /usr/share/nginx/html

# openresty lua-resty-upstream-healthcheck v0.08 a lua-resty-string v0.15 -
# Alpine je nebali, resp. lua-resty-string jen se zavislosti na celem openresty
COPY lua/ /usr/local/share/lua/5.1/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
