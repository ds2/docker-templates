# Build image for Operator-SDK on Gitlab

[![Docker Repository on Quay](https://quay.io/repository/ds2/operator-sdk-cicd/status "Docker Repository on Quay")](https://quay.io/repository/ds2/operator-sdk-cicd)

This image is for building kubernetes operators using the Operator SDK.

## How to build

Run:

    podman build -t operatorsdk:latest -f Containerfile .

## How to test

Run:

    docker run -it --rm operatorsdk:latest /bin/bash

## Release

Push to quay.io:

    ./buildAndPush.sh -d operator-sdk -r quay.io/ds2/operator-sdk-cicd -p

## Sources

* https://github.com/operator-framework/operator-sdk
