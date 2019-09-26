FROM azul/zulu-openjdk-alpine:8-jre
ARG jmeterVersion=5.1.1
VOLUME [ "/jmeter-src", "/jmeter-results","/jmeter-logs" ]
ENV JMETER_FILENAME=testplan.jmx
RUN mkdir -p /jmeter-logs; mkdir -p /jmeter-src; mkdir -p /jmeter-results; chmod 777 /jmeter-src /jmeter-logs /jmeter-results; apk update && apk --upgrade add bash zsh curl unzip tar
RUN mkdir -p /jmeter; curl -o /tmp/jmeter.zip -L http://apache.lauf-forum.at/jmeter/binaries/apache-jmeter-${jmeterVersion}.zip; unzip -d /tmp /tmp/jmeter.zip; cp -R /tmp/apache-jmeter-${jmeterVersion}/* /jmeter/; rm -rf /tmp/apache-jmeter-${jmeterVersion}; rm /tmp/*.zip
WORKDIR /jmeter-src
SHELL [ "/bin/zsh" ]
CMD [ "/runTest.sh" ]
ENTRYPOINT [ "/entrypoint.sh" ]
COPY entrypoint.sh /entrypoint.sh
COPY runTest.sh /runTest.sh
