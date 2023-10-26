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

After that you can build your image, and then:

    ./buildAndPush.sh -d MYDIRECTORY -r quay.io/ds2/myimage -p

Example:

    ./buildAndPush.sh -d rust-debian -r quay.io/ds2/rust-debian -b "linuxDistro=debian  distroVersion=bookworm" -t "bookworm bw-$(git rev-parse --short=8 HEAD)"
    ./buildAndPush.sh -d rust-debian -r quay.io/ds2/rust-debian -b "linuxDistro=debian  distroVersion=bullseye" -t "bullseye be-$(git rev-parse --short=8 HEAD)"
    ./buildAndPush.sh -d rust-debian -r quay.io/ds2/rust-debian -b "linuxDistro=ubuntu  distroVersion=jammy" -t "jammy jm-$(git rev-parse --short=8 HEAD)"
