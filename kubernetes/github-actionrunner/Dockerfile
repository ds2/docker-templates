FROM opensuse/leap:15
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
ENV JAVA_HOME=/usr/lib/jvm/zulu-11
RUN zypper --non-interactive up
RUN zypper --non-interactive in bash zsh curl docker unzip gzip libicu libunwind less
RUN useradd -c "Github Actionrunner User" -g users -m -s /bin/zsh ${USR}
RUN mkdir -p /work; chmod 777 /work; chown ${USR}:users /work
VOLUME [ "/work" ]

RUN rpm --import https://www.azul.com/files/0xB1998361219BD9C9.txt
RUN zypper --non-interactive in https://cdn.azul.com/zulu/bin/zulu11.43.55-ca-jdk11.0.9.1-linux.x86_64.rpm maven gradle

RUN zypper --non-interactive in nodejs npm

USER ${USR}
WORKDIR /home/${USR}
ADD entrypoint.sh /entrypoint.sh
SHELL [ "/bin/zsh" ,"-c"]
ADD ZSHRC.txt /home/${USR}/.zshrc
RUN pwd; curl -O -L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz; tar xzf ./actions-runner-linux-x64-${VERSION}.tar.gz
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/home/${USR}/run.sh" ]
