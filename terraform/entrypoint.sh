#!/usr/bin/env zsh

KEYDIR=/keys

mkdir -p $HOME/.aws

if [ -r $KEYDIR/aws-config ]; then
    cp $KEYDIR/aws-config /home/tignum/.aws/config
fi
if [ -r $KEYDIR/aws-credentials ]; then
    cp $KEYDIR/aws-config /home/tignum/.aws/credentials
fi

export PATH=/usr/local/bin:$PATH

terraform --version
aws --version
az --version

eval "$@"
