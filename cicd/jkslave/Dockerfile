FROM jenkins/jnlp-slave:3.29-1-alpine
LABEL version="3.29.1"
USER root
RUN apk update && apk upgrade; apk add maven=~3.6 gradle
USER jenkins
