#!/usr/bin/env bash

FILES=$(find $PG_CONFS_DIR -type f -name "*.sample")
for f in $FILES; do
    echo "Copying file $f to postgres poststart config"
    cp $PG_CONFS_DIR/$f /usr/local/share/postgresql/
done
