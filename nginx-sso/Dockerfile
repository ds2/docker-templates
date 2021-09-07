FROM openresty/openresty:1.19.3.1-alpine
MAINTAINER Hans Kristian Flaatten <hans.flaatten@evry.com>
EXPOSE 80 8080

ENV \
    HTTP_VERSION=0.12 \
    OPENIDC_VERSION=1.6.1 \
    HMAC_VERSION=989f601acbe74dee71c1a48f3e140a427f2d03ae
ENV OIDC_CLIENTID=myClientId
ENV OIDC_CLIENTSECRET=myClientSecret
RUN apk update && apk upgrade && apk add curl perl
RUN \
    cd /tmp && \
    curl -sSL https://github.com/pintsized/lua-resty-http/archive/v${HTTP_VERSION}.tar.gz | tar xz  && \
    curl -sSL https://github.com/jkeys089/lua-resty-hmac/archive/${HMAC_VERSION}.tar.gz | tar xz && \
    cp -r /tmp/lua-resty-http-${HTTP_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
    cp -r /tmp/lua-resty-hmac-${HMAC_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
    rm -rf /tmp/* && \
    mkdir -p /usr/local/openresty/nginx/conf/hostsites/ && \
    true
RUN opm install zmartzone/lua-resty-openidc
COPY proxyconfig.conf /etc/nginx/conf.d/proxyconfig.conf

# ENTRYPOINT ["/usr/local/openresty/bootstrap.sh"]
