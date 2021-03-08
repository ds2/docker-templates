#!/usr/bin/env bash

echo "Here we would run the JNDI registration.."

DOMAIN="${DOMAIN:-domain1}"

cp /libs/*.jar ${PAYARA_DIR}/glassfish/domains/${DOMAIN}/lib/

POSTBOOTCMDS="${CONFIG_DIR}/post-boot-commands.asadmin"

# if [ ! -z "${JNDI_1_ID}" ]; then
#     echo "create-jdbc-connection-pool --datasourceclassname=org.postgresql.ds.PGConnectionPoolDataSource --restype javax.sql.ConnectionPoolDataSource --property \"user=n8w8dev:password=n8w8dev:serverName=localhost:portNumber=5433:databaseName=n8w8devdb\" --ping=true --steadypoolsize=1 --maxpoolsize=10 --maxwait=15000 --poolresize=2 --initsql=\"select 1\" --leaktimeout=300 --statementleaktimeout=240 --creationretryattempts=3 --statementtimeout=200 --statementcachesize=50 --description=\"the n8w8 jdbc pool\" ${JNDI_1_ID}" >>$POSTBOOTCMDS
#     echo "create-jdbc-resource --connectionpoolid ${JNDI_1_ID} --description=\"The jndi link to the n8w8 jdbc pool\" jdbc/n8w8" >>$POSTBOOTCMDS
# fi

function fn() {
    echo ${!1}
}

function join_by() {
    # local IFS=":"
    # shift
    # echo "$*"
    local separator=':'
    local first="$1"
    shift
    printf "%s" "$first" "${@/#/$separator}"
}

function printAsAdm() {
    local id=$1
    local headerName="\$JNDI_${id}"
    local JNDI_ID=$(fn JNDI_${id}_ID)
    local JNDI_DSCLASS=$(fn JNDI_${id}_DSCLASS)
    local JNDI_PROPS=$(fn JNDI_${id}_PROPS)
    local JNDI_MINSIZE=$(fn JNDI_${id}_MINSIZE)
    local JNDI_MAXSIZE=$(fn JNDI_${id}_MAXSIZE)
    local JNDI_MAXWAIT=$(fn JNDI_${id}_MAXWAIT)
    local JNDI_INITSQL=$(fn JNDI_${id}_INITSQL)
    local JNDI_DESCR=$(fn JNDI_${id}_DESCR)
    local JNDI_STATT0=$(fn JNDI_${id}_STATT0)
    local JNDI_RESIZE=$(fn JNDI_${id}_RESIZE)
    local JNDI_STCACHE=$(fn JNDI_${id}_STCACHE)
    local JNDI_LEAKT0=$(fn JNDI_${id}_LEAKT0)
    local JNDI_STLEAKT0=$(fn JNDI_${id}_STLEAKT0)
    local JNDI_USER=$(fn JNDI_${id}_USER)
    local JNDI_PW=$(fn JNDI_${id}_PW)
    local JNDI_PORT=$(fn JNDI_${id}_PORT)
    local JNDI_HOSTNAME=$(fn JNDI_${id}_HOSTNAME)
    local JNDI_DBNAME=$(fn JNDI_${id}_DBNAME)
    local JNDI_DSNAME=$(fn JNDI_${id}_DSNAME)
    local JNDI_URL=$(fn JNDI_${id}_URL)
    local JNDI_MAXCONNUSE=$(fn JNDI_${id}_MAXCONNUSE)
    local JNDI_SHOWSQL=$(fn JNDI_${id}_SHOWSQL)
    if [ -z "$JNDI_ID" ]; then
        echo ""
    else
        CMD="create-jdbc-connection-pool --restype javax.sql.ConnectionPoolDataSource --ping=true  --maxwait=${JNDI_MAXWAIT:-2000} --initsql=\"${JNDI_INITSQL:-select 1}\"  --pooling=true"
        # asadmin set domain.resources.jdbc-connection-pool.__TimerPool.slow-query-threshold-in-seconds=50
        CMD="$CMD --validateatmostonceperiod=300"
        CMD="$CMD --poolresize=${JNDI_RESIZE:-2} --steadypoolsize=${JNDI_MINSIZE:-0} --maxpoolsize=${JNDI_MAXSIZE:-5}"
        CMD="$CMD --statementtimeout=${JNDI_STATT0:-0} --statementcachesize=${JNDI_STCACHE:-0}"
        # CMD="$CMD --statementleaktimeout=${JNDI_STATT0:-5}"
        if [ -n "$JNDI_LEAKT0" ]; then
            CMD="$CMD --leaktimeout=${JNDI_LEAKT0:-0} --leakreclaim=true"
        fi
        if [ -n "$JNDI_STLEAKT0" ]; then
            CMD="$CMD --statementleaktimeout=${JNDI_STLEAKT0} --statementleakreclaim=true"
        fi
        CMD="$CMD --creationretryattempts=3 --creationretryinterval=9"
        CMD="$CMD --logjdbccalls=${JNDI_SHOWSQL:-false}"
        CMD="$CMD --maxconnectionusagecount=${JNDI_MAXCONNUSE:-0}"
        #  set resources.jdbc-connection-pool.test-pool.statement-leak-timeout-in-seconds=5
        #asadmin> set resources.jdbc-connection-pool.test-pool.connection-leak-timeout-in-seconds=5
        if [ ! -z "$JNDI_DSCLASS" ]; then
            CMD="$CMD --datasourceclassname=${JNDI_DSCLASS}"
        else
            echo "You must tell what DS class can be used! Set ENV var ${headerName}_DSCLASS!"
            exit 1
        fi
        if [ ! -z "$JNDI_DESCR" ]; then
            CMD="$CMD --description=\"${JNDI_DESCR}\""
        fi
        PROPS=""
        if [ ! -z "$JNDI_PROPS" ]; then
            PROPS="$JNDI_PROPS"
        else
            PROPARRAY=()
            if [ -n "$JNDI_USER" ]; then
                PROPARRAY+=("user=$JNDI_USER")
            fi
            if [ -n "$JNDI_PW" ]; then
                PROPARRAY+=("password=$JNDI_PW")
            fi
            if [ -n "$JNDI_PORT" ]; then
                PROPARRAY+=("portNumber=$JNDI_PORT")
            fi
            if [ -n "$JNDI_HOSTNAME" ]; then
                PROPARRAY+=("serverName=$JNDI_HOSTNAME")
            fi
            if [ -n "$JNDI_DBNAME" ]; then
                PROPARRAY+=("databaseName=$JNDI_DBNAME")
            fi
            if [ -n "$JNDI_URL" ]; then
                PROPARRAY+=("url=$JNDI_URL")
            fi
            # echo "# Props are ${PROPARRAY[@]} -> ${PROPARRAY}"
            PROPS=$(join_by "${PROPARRAY[@]}")
        fi
        if [ ! -z "$PROPS" ]; then
            CMD="$CMD --property \"${PROPS}\""
        fi
        CMD="$CMD $JNDI_ID"
        echo "$CMD"
    fi
}

for name in {1..5}; do
    JNDI_ID=$(fn JNDI_${name}_ID)
    if [ ! -z "$JNDI_ID" ]; then
        JNDI_SLOWQUERY=$(fn JNDI_${name}_SLOWQUERY)
        JNDI_JNDI=$(fn JNDI_${name}_JNDI)
        JNDI_DESCR=$(fn JNDI_${id}_DESCR)
        JNDI_STLEAKT0=$(fn JNDI_${id}_STLEAKT0)
        echo $(printAsAdm $name) >>$POSTBOOTCMDS
        echo "set domain.resources.jdbc-connection-pool.${JNDI_ID}.slow-query-threshold-in-seconds=${JNDI_SLOWQUERY:-10}" >>$POSTBOOTCMDS
        echo "set domain.resources.jdbc-connection-pool.${JNDI_ID}.statement-leak-timeout-in-seconds=${JNDI_STLEAKT0:-5}" >>$POSTBOOTCMDS
        echo "set domain.resources.jdbc-connection-pool.${JNDI_ID}.statement-leak-reclaim=true" >>$POSTBOOTCMDS
        if [ ! -z "$JNDI_JNDI" ]; then
            echo "create-jdbc-resource --connectionpoolid ${JNDI_ID} --description=\"${JNDI_DESCR:-my sample dummy jndi}\" $JNDI_JNDI" >>$POSTBOOTCMDS
        fi
    fi
done

cat $POSTBOOTCMDS

# exit 1
