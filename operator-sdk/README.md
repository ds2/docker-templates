# Build image for Operator-SDK on Gitlab

This image is for building kubernetes operators using the Operator SDK.

## How to build

Run:

    docker build -t operatorsdk:latest .

## How to test

Run:

    docker run -it --rm operatorsdk:latest /bin/bash

## Release

Push to quay.io:

    docker tag operatorsdk:latest quay.io/ds2/operator-sdk-cicd:latest
    docker push quay.io/ds2/operator-sdk-cicd:latest
