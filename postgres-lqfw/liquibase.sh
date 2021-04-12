#!/usr/bin/env bash

export PATH=$PATH:${LQ_BIN_DIR}

function performLqCall(){
    local dbName=$1
    echo "- will sleep for $LQ_SLEEP seconds.."
    sleep $LQ_SLEEP
    local lqDataExecDir="/tmp/lq-${dbName}"
    
}

cd $DATA_DIR
DATABASES=$(find $DATA_DIR -type d)
for d in $DATABASES; do
    echo "Checking directory $d for db yaml file"
    YAMLFILE="$DATA_DIR/${d}/${d}.yaml"
    if [ -f "$YAMLFILE" ]; then
        echo "found database file, will schedule execution in the future"
        performLqCall "$d" &
    fi
done

echo "Done."
