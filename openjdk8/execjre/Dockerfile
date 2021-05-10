FROM openjdk:8-jre-slim
EXPOSE 8080 5151
ARG userId=1000
ARG groupId=1000
VOLUME [ "/app" ]
RUN addgroup --gid ${groupId} jrunners
RUN useradd -m -s /bin/bash -g jrunners -u ${userId} jrun
COPY runJar.sh /runJar.sh
RUN apt-get update; apt-get -y upgrade; apt-get install -y less
RUN rm -rf /var/lib/apt/lists/* && apt-get purge --auto-remove && apt-get clean
ENV JAVA_SYSTEM_PROPS "-Dmy.env=test -Dthis.Env=test"
ENTRYPOINT [ "/runJar.sh" ]
USER jrun
