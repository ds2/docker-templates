FROM jetbrains/teamcity-agent:2022.10.1-linux-sudo
USER root
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN curl -o /tmp/repo.deb -L https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb; apt-get install -y -f /tmp/repo.deb; curl -L https://apt.corretto.aws/corretto.key | apt-key add - ;\
    add-apt-repository 'deb https://apt.corretto.aws stable main'; apt-get update
RUN apt-get install --no-install-recommends -y zulu11-jdk
RUN apt autoremove; apt-get -y upgrade; rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME="/usr/lib/jvm/zulu11"
ENV PATH=${JAVA_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JRE_HOME=${JAVA_HOME}/jre
ENV JDK_11=${JAVA_HOME}
RUN update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 2082; update-alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 2082
USER buildagent
