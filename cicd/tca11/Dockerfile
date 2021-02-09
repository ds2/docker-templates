FROM jetbrains/teamcity-agent:2020.2.2-linux-sudo
USER root
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN curl -o /tmp/repo.deb -L https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb; apt-get install -y -f /tmp/repo.deb; curl -L https://apt.corretto.aws/corretto.key | apt-key add - ;\
    add-apt-repository 'deb https://apt.corretto.aws stable main'; apt-get update
RUN apt-get install --no-install-recommends -y zulu11-jdk
RUN apt autoremove; apt-get -y upgrade; rm -rf /var/lib/apt/lists/*
USER buildagent
RUN export PATH=/usr/lib/jvm/zulu11/bin:$PATH
ENV PATH=/usr/lib/jvm/zulu11/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
