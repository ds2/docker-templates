FROM opensuse/leap:15
ARG USR=gitrunner
ARG VERSION=2.274.2
ENV REPOTOKEN MYSECRETTOKEN
ENV REPOURL https://github.com/my/path/to/repo
ENV LANG de_DE.UTF-8
# ENV LC_ALL de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
RUN zypper --non-interactive up; zypper --non-interactive in bash zsh curl docker unzip gzip
RUN useradd -c "Github Actionrunner User" -g users -m -s /bin/zsh ${USR}
ADD entrypoint.sh /entrypoint.sh
USER ${USR}
WORKDIR /home/${USR}
SHELL [ "/bin/zsh" ,"-c"]
ADD ZSHRC.txt /home/${USR}/.zshrc
RUN pwd; curl -O -L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz; tar xzf ./actions-runner-linux-x64-2.274.2.tar.gz
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/home/${USR}/run.sh" ]
