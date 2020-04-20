#!/usr/bin/env bash

echo "Using cmd with user $USER $(id -u): $@"

export PATH=$PATH:/jmeter/bin

if [ ! -w /jmeter-logs ]; then
    echo "(!) Cannot write into logs dir!! There may be issues in the future!!"
    exit 1
fi
if [ ! -w /jmeter-results ]; then
    echo "(!) Cannot write into results dir!! There may be issues in the future!!"
    exit 2
fi

eval "$@"
