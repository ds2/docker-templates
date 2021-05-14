FROM alpine:3.13
EXPOSE 80

RUN echo "https://mirror.leaseweb.com/alpine/v3.13/community" >> /etc/apk/repositories
RUN echo "https://openresty.org/package/alpine/v3.13/main" >> /etc/apk/repositories
RUN apk --no-cache add curl
RUN curl -o /etc/apk/keys/openresty.rsa.pub -L https://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub
RUN curl -o /etc/apk/keys/openresty2.rsa.pub -L https://openresty.org/package/pubkey.gpg
RUN apk update
RUN apk add --no-cache nginx-mod-http-lua luajit nginx luarocks openresty
# Create folder for PID file
RUN mkdir -p /run/nginx

# Delete default config
#RUN rm -r /etc/nginx/conf.d && rm /etc/nginx/nginx.conf

# Add our nginx conf
# COPY ./nginx.conf /etc/nginx/nginx.conf

CMD ["nginx"]
