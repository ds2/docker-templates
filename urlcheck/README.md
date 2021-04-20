# Dummy URL Checker

A dummy url checker written in Rust.

## How to build

Run:

    docker build -t urlchecker:latest .

## How to Test

    docker run -it --rm -e URL=https://www.pcwelt.de/ urlchecker:latest
