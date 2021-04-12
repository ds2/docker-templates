#!/usr/bin/env bash

echo "Hello World ;)"

export PATH=$PATH:/usr/local/bin

cp $LQ_SH_DIR/*.sh  /docker-entrypoint-initdb.d/

/docker-entrypoint.sh "$@"
echo "done with RC=$?"
