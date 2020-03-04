FROM openjdk:11-jre-slim
# RUN apt-get -y update && apt-get -y upgrade libidn2 e2fsprogs
# RUN rm -rf /var/lib/apt/lists/* && apt-get purge --auto-remove && apt-get clean
EXPOSE 8080 5151
VOLUME [ "/app" ]
ENV JAVA_SYSTEM_PROPS "-Dmy.env=test -Dthis.Env=test"
ENTRYPOINT ["java","$JAVA_SYSTEM_PROPS","-jar","/app/app.jar"]
