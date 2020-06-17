FROM jenkins/jnlp-slave:4.3-4-alpine
LABEL version="4.3-4"
USER root
RUN apk update && apk upgrade; apk add maven=~3.6 gradle git; ln -s /usr/share/java/maven-3 /opt/maven3
#RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories \
    && apk upgrade -U -a \
    && apk add --no-cache libstdc++ chromium harfbuzz nss freetype ttf-freefont wqy-zenhei nodejs npm xvfb x11vnc fluxbox xdpyinfo st vim terminus-font libnotify nss libxtst xauth \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk
ENV MAVEN_HOME=/opt/maven3
USER jenkins
