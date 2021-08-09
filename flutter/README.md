# Flutter CICD client for Android/web

## How to build

    docker build -t flutter-cicd:latest .

## How to test

    docker run -it --rm -v $(pwd):/src flutter-cicd:latest
