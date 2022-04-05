FROM alpine:3.15.4
ARG MON_DIR=/watch
ENV SEC_DIR /secrets
ENV HOST_ID myHostId
RUN apk add --no-cache inotify-tools aws-cli python3 bash
RUN adduser -s /bin/bash -G users -D reader; mkdir ${SEC_DIR} ${MON_DIR} /scripts; chmod 0777 ${SEC_DIR} ${MON_DIR} /scripts
USER reader
WORKDIR /home/reader
ADD notify.sh /scripts/notify.sh
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
