#!/usr/bin/env bash

echo "Will start jar via /app/app.jar"

if [ ! -f /app/app.jar ]; then
    echo "No app.jar found in /app! Will exit now."
    exit 1
fi

java $JAVA_SYSTEM_PROPS -jar /app/app.jar "$@"
