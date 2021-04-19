#!/usr/bin/env bash

DOMAIN_DIR=${PAYARA_DIR}/glassfish/domains/${DOMAIN_NAME}

if [ ! -d "$DOMAIN_DIR" ]; then
    echo "NO domain Dir found in $DOMAIN_DIR"
    exit 1
fi

if [ -f ${JEE_CONFIGS_DIR}/logging.properties ]; then
    echo "Replacing logging properties.."
    cp ${JEE_CONFIGS_DIR}/logging.properties $DOMAIN_DIR/config/
fi
