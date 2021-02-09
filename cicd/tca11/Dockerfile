FROM jetbrains/teamcity-agent:2020.2.2-linux-sudo
USER root
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN curl -L https://apt.corretto.aws/corretto.key | apt-key add - ;\
    add-apt-repository 'deb https://apt.corretto.aws stable main'; apt-get update
RUN apt-get install --no-install-recommends -y java-15-amazon-corretto-jdk
RUN apt autoremove; apt-get -y upgrade; rm -rf /var/lib/apt/lists/*
USER buildagent
ENV JAVA_HOME=/usr/lib/jvm/java-15-amazon-corretto
ENV PATH=${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JRE_HOME=${JAVA_HOME}/jre
