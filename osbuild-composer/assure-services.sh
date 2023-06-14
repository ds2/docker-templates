#!/usr/bin/env bash

OSB_SVC=CMP_SERVICES="osbuild-composer.service osbuild-composer.socket osbuild-composer-api.socket osbuild-local-worker.socket"

for s in $OSB_SVC; do
    systemctl status $s
done
