FROM azul/zulu-openjdk-alpine:8-jre
EXPOSE 8080 5151
VOLUME [ "/app" ]
ENV JAVA_SYSTEM_PROPS "-Dmy.env=test -Dthis.Env=test"
COPY runJar.sh /runJar.sh
ENTRYPOINT [ "/runJar.sh" ]
