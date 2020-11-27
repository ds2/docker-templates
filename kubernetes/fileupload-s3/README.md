# Dump uploader

## How to build

    docker build -t delme:latest .

## How to test

    docker run -it --rm -e HOST_ID=local -v $(pwd):/watch delme:latest
