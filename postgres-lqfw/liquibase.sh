#!/usr/bin/env bash

export PATH=$PATH:${LQ_BIN_DIR}

function performLqCall(){
    local dbName=$1
    echo "- will sleep for $LQ_SLEEP seconds.."
    sleep $LQ_SLEEP
    local lqDataExecDir="/tmp/lq-${dbName}"
    mkdir -p $lqDataExecDir
    cp $DATA_DIR/${d}/*.yaml $lqDataExecDir/
    cd $lqDataExecDir
    if [ -f liquibase.properties ]; then
        echo "found lq props file, ignoring creation"
    else
        cat <<EOF >$lqDataExecDir/liquibase.properties
changeLogFile=${dbName}.yaml
logFile=${LOGS_DIR}/${dbName}.log
logLevel=info
url=jdbc:postgresql://localhost:5432/${dbName}
username=${POSTGRES_USER}
password=${POSTGRES_PASSWORD}
# liquibaseSchemaName=public
driver=org.postgresql.Driver
classpath=/db-libs/postgresql.jar
liquibase.hub.mode=off
EOF
    fi
    liquibase --contexts="${LQ_CTXS}" update
    liquibase --contexts="${LQ_CTXS}" validate
}

cd $DATA_DIR
DATABASES=$(find . -type d)
for d in $DATABASES; do
    if [ "." = "$d" ]; then
        continue
    fi
    if [[ "$d" =~ ^\./.* ]]; then
        d="${d:2}"
    fi
    echo "Checking directory $d for db yaml file"
    YAMLFILE="$DATA_DIR/${d}/${d}.yaml"
    if [ -f "$YAMLFILE" ]; then
        echo "found database file, will schedule execution in the future"
        performLqCall "$d" &
    else
        echo "No yaml file $YAMLFILE found, ignoring."
    fi
done

echo "Done."
