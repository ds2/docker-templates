# TeamCity Build Agent with Java 15

[![Docker Repository on Quay](https://quay.io/repository/ds2/tc-buildagent-15/status "Docker Repository on Quay")](https://quay.io/repository/ds2/tc-buildagent-15)

TeamCity is the CICD solution from Jetbrains. Check them out.

I use their base image <https://hub.docker.com/r/jetbrains/teamcity-agent> to create an agent with java 15.

## How to build

    docker build -t tca15:latest .

## How to test

    docker run -it --rm tca15:latest java -version
    export TC_URL=...
    docker run -it --rm -e AGENT_NAME=testbuild1 -e SERVER_URL=$TC_URL -e DOCKER_IN_DOCKER=start tca15:latest
