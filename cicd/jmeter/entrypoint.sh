#!/usr/bin/env bash

echo "Using cmd: $@"

export PATH=$PATH:/jmeter/bin

eval "$@"
