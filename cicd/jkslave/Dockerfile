FROM jenkins/jnlp-slave:4.3-4-alpine
LABEL version="4.3-4"
USER root
RUN apk update && apk upgrade; apk add maven=~3.6 gradle git; ln -s /usr/share/java/maven-3 /opt/maven3
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk add nodejs@testing npm@testing
ENV MAVEN_HOME=/opt/maven3
USER jenkins
