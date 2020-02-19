FROM openjdk:8-jre-slim
# RUN apt-get -y update && apt-get -y upgrade
# RUN rm -rf /var/lib/apt/lists/* && apt-get purge --auto-remove && apt-get clean
EXPOSE 8080 5151
VOLUME [ "/app" ]
ENTRYPOINT ["java","-jar","/app/app.jar"]
