FROM azul/zulu-openjdk-alpine:20
RUN apk update; apk upgrade; apk --update add --no-cache gradle maven bash zsh git
WORKDIR /src
ENV JAVA_HOME=/usr/lib/jvm/zulu8
ENV LANG=de_DE.UTF-8
RUN rm /usr/lib/jvm/default-jvm; ln -s ${JAVA_HOME} /usr/lib/jvm/default-jvm
RUN adduser -s /bin/zsh -D -u 1000 cicd
RUN rm -rf /var/cache/apk/*

USER cicd
RUN touch ~/.zshrc; echo "PROMPT=\"%h-\u231a %* %n@%m: %~ > \"" > ~/.zshrc
RUN echo "PS1=\$'\U1F4BB%m \U1F9D1%n \U1F4C2%~\n\U231a %* $ '" >> ~/.zshrc
CMD ["/bin/zsh" ]
