FROM alpine:3.17.2
RUN apk upgrade --update-cache --available
RUN apk add texlive bash
RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community pandoc
RUN adduser -s /bin/bash -u 1000 -D latex
RUN mkdir /workspace; chown -R latex /workspace
SHELL [ "/bin/bash" ]
USER latex
WORKDIR /workspace
