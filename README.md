# docker-templates

Some docker templates to work with kubernetes/docker etc.

## Building the images

Simply run

    docker build --rm -f "openjdk8/execjre/Dockerfile" -t dstrauss/execjre:v1 openjdk8/execjre

## Test the image

Via

    docker run -it --rm dstrauss/execjre:v1 "hello" "world"
