#!/usr/bin/env bash

export PATH=$PATH:${LQ_BIN_DIR}

function performLqCall() {
    local dbName=$1
    echo "- waiting ${LQ_SLEEP} seconds for Liquibase execution.."
    while true; do
        exec 6<>/dev/tcp/127.0.0.1/5432 || sleep 1
        break
    done
    local lqDataExecDir="/tmp/lq-${dbName}"
    mkdir -p $lqDataExecDir
    cp -r $DATA_DIR/${d}/* $lqDataExecDir/
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
# liquibaseSchemaName=s1
driver=org.postgresql.Driver
classpath=/db-libs/postgresql.jar
liquibase.hub.mode=off
EOF
    fi
    liquibase --contexts="${LQ_CTXS}" update
    liquibase --contexts="${LQ_CTXS}" validate
}

function printDatabaseSchemas() {
    local dataDir=$1
    local dbName=$2
    local dbDirectory="$dataDir/$dbName"
    cd $dbDirectory
    DIRECTORIES=$(find . -type d)
    COUNT_DIRECTORIES=$(echo "$DIRECTORIES" | wc -l)
    if [ $COUNT_DIRECTORIES -gt 1 ]; then
        for s in $DIRECTORIES; do
            if [ "." = "$d" ]; then
                continue
            fi
            if [[ "$s" =~ ^\./.* ]]; then
                s="${s:2}"
            fi
            local yamlFile=$dataDir/$dbName/${s}/${dbName}.yaml
            if [ -f "$yamlFile" ]; then
                echo "$s"
            fi
        done
    fi
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
    printDatabaseSchemas "$DATA_DIR" "$d"
    YAMLFILE="$DATA_DIR/${d}/${d}.yaml"
    if [ -f "$YAMLFILE" ]; then
        echo "found public database file, will schedule execution in the future"
        performLqCall "$d" &
    else
        echo "No yaml file $YAMLFILE found, ignoring."
    fi
done

echo "Done."
