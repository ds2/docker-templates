# docker-templates

Some docker templates to work with kubernetes/docker etc.

## Building the images

Simply run

    docker build --rm -f "openjdk8/execjre/Dockerfile" -t dstrauss/execjre:v1 openjdk8/execjre

## Test the image

Via

    docker run -it --rm dstrauss/execjre:v1 "hello" "world"

## Quay.io as our main hoster

In case the quay.io builder is not working due to "requestlimit" issues, you can create the image locally and push it to Quay.io:

    docker login quay.io

Use your quay.io Username and the "Docker CLI" encrypted password to login.
