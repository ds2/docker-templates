[![Docker Repository on Quay](https://quay.io/repository/ds2/cicd-17/status "Docker Repository on Quay")](https://quay.io/repository/ds2/cicd-17)

# CICD Java 17 image

An image to be used in IntelliJ to run projects with a non-ide java version.

## How to build this image

Run:

    docker build -t quay.io/ds2/cicd-17:latest .

## How to test

Run:

    docker run -it --rm quay.io/ds2/cicd-17:latest
