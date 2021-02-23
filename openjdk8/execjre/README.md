# DS/2 Exec-Jre 8

[![Docker Repository on Quay](https://quay.io/repository/ds2/exec-jre/status "Docker Repository on Quay")](https://quay.io/repository/ds2/exec-jre)

To run a single jar in its own environment.

* The executable jar must be put in /app/app.jar
* system properties can be given via the ENV variable JAVA_SYSTEM_PROPS
* any command line parameters can be given directly by appending them to the docker run command

## How to build

    docker build -t execjre8:latest .

## How to test

    docker run -it --rm --entrypoint "" execjre8:latest /bin/bash