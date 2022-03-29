FROM alpine:3.15.3
RUN apk upgrade --update-cache --available
RUN apk add texlive bash
RUN adduser -s /bin/bash -u 1000 -D latex
RUN mkdir /workspace; chown -R latex /workspace
SHELL [ "/bin/bash" ]
USER latex
WORKDIR /workspace
