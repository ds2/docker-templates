FROM azul/zulu-openjdk-alpine:11.0.22-jre
EXPOSE 8080 5151
ARG userId=1000
ARG groupId=1000
VOLUME [ "/app" ]
RUN apk update; apk add bash
RUN addgroup -g ${groupId} jrunners
RUN adduser -s /bin/bash -G jrunners -D -u ${userId} jrun
COPY runJar.sh /runJar.sh
ENV JAVA_SYSTEM_PROPS "-Dmy.env=test -Dthis.Env=test"
ENTRYPOINT [ "/runJar.sh" ]
USER jrun
