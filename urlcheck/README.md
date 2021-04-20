# Dummy URL Checker

A dummy url checker written in Rust. The idea is to run this image in a kubernetes cluster as
a cronjob so that you get a urlcheck every minute etc. and you may report the errored urls
via a bash script to someone. As a sample I will provide here OpsGenie to test with.

## How to build

Run:

    docker build -t urlchecker:latest .

## How to Test

    docker run -it --rm -e URL=https://www.pcwelt.de/ urlchecker:latest
