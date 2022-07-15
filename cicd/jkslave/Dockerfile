FROM jenkins/jnlp-slave:4.13.2-1-jdk11
LABEL version="4.6-1-jdk11"
USER root
RUN apt-get update; \
    apt-get -y upgrade; \
    apt-get -y install maven git gradle; \
    apt-get -y install yarn nodejs npm libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb chromium;
# RUN apk update && apk upgrade; apk add maven=~3.6 gradle git; ln -s /usr/share/java/maven-3 /opt/maven3
# #RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
# RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
#     && echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories \
#     && apk upgrade -U -a \
#     && apk add --no-cache libstdc++ chromium harfbuzz nss freetype ttf-freefont wqy-zenhei nodejs npm xvfb x11vnc fluxbox xdpyinfo st vim terminus-font libnotify nss libxtst xauth \
#     && rm -rf /var/cache/* \
#     && mkdir /var/cache/apk
ENV MAVEN_HOME=/opt/maven3
USER jenkins
