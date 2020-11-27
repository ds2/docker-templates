#!/usr/bin/env bash

export MON_DIR=/watch
export AWS_BUCKET=$AWS_BUCKET
export SEC_DIR=/secrets
export HOSTID=${HOSTID:-myHostId}

echo "Starting monitoring of $MON_DIR.."
inotifywait -m $MON_DIR -e close_write | while read path action file; do
    srcFile="$path$file"
    echo "File $srcFile has changed.."
    /scripts/notify.sh $srcFile
done
