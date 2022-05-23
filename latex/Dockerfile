FROM alpine:3.16.0
RUN apk upgrade --update-cache --available
RUN apk add texlive bash
RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing pandoc
RUN adduser -s /bin/bash -u 1000 -D latex
RUN mkdir /workspace; chown -R latex /workspace
SHELL [ "/bin/bash" ]
USER latex
WORKDIR /workspace
