FROM azul/zulu-openjdk-alpine:8-jre
ARG jmeterVersion=5.2.1
ENV JMETER_FILENAME=testplan.jmx
RUN mkdir -p /jmeter-logs; mkdir -p /jmeter-src; mkdir -p /jmeter-results; chmod 777 /jmeter-src; chmod 777 /jmeter-logs; chmod 777 /jmeter-results
RUN apk update && apk --upgrade add bash zsh curl unzip tar
ADD jmeter-${jmeterVersion}.zip /tmp/jmeter.zip
RUN mkdir -p /jmeter; unzip -d /tmp /tmp/jmeter.zip; cp -R /tmp/apache-jmeter-${jmeterVersion}/* /jmeter/; rm -rf /tmp/apache-jmeter-${jmeterVersion}; rm /tmp/*.zip
COPY entrypoint.sh /entrypoint.sh
COPY runTest.sh /runTest.sh
WORKDIR /jmeter-src
SHELL [ "/bin/zsh" ]
CMD [ "/runTest.sh" ]
ENTRYPOINT [ "/entrypoint.sh" ]
VOLUME [ "/jmeter-src", "/jmeter-results","/jmeter-logs" ]
