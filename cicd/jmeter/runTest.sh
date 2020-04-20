#!/usr/bin/env bash

JM_RESULTS=/jmeter-results
JM_LOGS=/jmeter-logs
JM_SRC=/jmeter-src
# JM_PROPS must be given by ENV

MYCMD="jmeter -n -t ${JM_SRC}/$JMETER_FILENAME -l ${JM_RESULTS}/sample-results.jtl -j ${JM_LOGS}/jmeter.log -e -o ${JM_RESULTS} ${JM_PROPS}"

echo "Will run now: $MYCMD"

eval "$MYCMD"
