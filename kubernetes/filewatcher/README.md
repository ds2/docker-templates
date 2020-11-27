# Dump uploader

[![Docker Repository on Quay](https://quay.io/repository/ds2/filewatcher/status "Docker Repository on Quay")](https://quay.io/repository/ds2/filewatcher)

## How to build

    docker build -t delme:latest .

## How to test

    docker run -it --rm -e HOST_ID=local -v $(pwd):/watch delme:latest
    touch "test 1" > $(pwd)/delme1.txt
