# Github ActionRunner sample

[![Docker Repository on Quay](https://quay.io/repository/ds2/github-actionrunner/status "Docker Repository on Quay")](https://quay.io/repository/ds2/github-actionrunner)

A dummy container serving Java 11, Maven 3.6 and Gradle 4 as basic tools for CI support in Github as action runner. The idea is to run this on your machine or your server environment as support for GH actions.

## Build it

    docker build -t quay.io/ds2/github-actionrunner:latest .

## Test it first

    docker run -it --rm quay.io/ds2/github-actionrunner:latest /bin/zsh

## Final Test

    docker run -it --rm -e REPOURL=https://github.com/my/repo/url -e REPOTOKEN=MYTOKEN quay.io/ds2/github-actionrunner:latest
