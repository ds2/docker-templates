FROM jenkins/jnlp-slave:3.29-1-alpine
LABEL version="3.29.1"
USER root
RUN apk update && apk upgrade; apk add maven=~3.6 gradle git; ln -s /usr/share/java/maven-3 /opt/maven3
ENV MAVEN_HOME=/opt/maven3
USER jenkins
