#!/usr/bin/env bash
echo "Will configure this container now.."
./config.sh --url $REPOURL --token $REPOTOKEN
eval $@
