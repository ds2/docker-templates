FROM ubuntu:21.04
ARG USR=gitrunner
ARG VERSION=2.278.0
ENV HOSTNAME=myrunner01
ENV REPOTOKEN=MYSECRETTOKEN
ENV REPOURL=https://github.com/my/path/to/repo
ENV LANG=de_DE.UTF-8
ENV USR=${USR}
ENV LABELS="localtest,dkr,mylabel1"
# ENV LC_ALL de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/zulu-11-amd64
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update; apt-get -y upgrade
RUN apt-get install -y curl gnupg2

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN curl -o /tmp/zulu.deb https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb
RUN apt-get install /tmp/zulu.deb; apt-get update
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime; apt-get install -y --no-install-recommends tzdata

RUN apt-get install -y bash zsh docker unzip gzip less gnupg2 maven gradle nodejs npm zulu-11 git
RUN useradd -c "Github Actionrunner User" -g users -m -s /bin/zsh ${USR}
RUN mkdir -p /work; chmod 777 /work; chown ${USR}:users /work
VOLUME [ "/work" ]

USER ${USR}
WORKDIR /home/${USR}
ADD entrypoint.sh /entrypoint.sh
SHELL [ "/bin/zsh" ,"-c"]
ADD health.sh /health.sh
ADD ZSHRC.txt /home/${USR}/.zshrc
RUN pwd; curl -O -L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz; tar xzf ./actions-runner-linux-x64-${VERSION}.tar.gz
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/home/${USR}/run.sh" ]
