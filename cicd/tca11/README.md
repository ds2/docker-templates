# TeamCity Build Agent with Java 11

[![Docker Repository on Quay](https://quay.io/repository/ds2/tc-buildagent-11/status "Docker Repository on Quay")](https://quay.io/repository/ds2/tc-buildagent-11)

TeamCity is the CICD solution from Jetbrains. Check them out.

I use their base image <https://hub.docker.com/r/jetbrains/teamcity-agent> to create an agent with java 11.

## How to build

    docker build -t tca11:latest .

## How to test

    docker run -it --rm tca11:latest java -version
    export TC_URL=...
    docker run -it --rm -e AGENT_NAME=testbuild1 -e SERVER_URL=$TC_URL -e DOCKER_IN_DOCKER=start tca11:latest
