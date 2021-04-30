#!/usr/bin/env bash

export PATH=$PATH:/home/awsusr/.local/bin
mkdir $HOME/.aws

cat <<EOF >${AWS_CONFIG_FILE}
[${AWS_PROFILE}]
region = ${AWS_DEFAULT_REGION}
output = ${AWS_DEFAULT_OUTPUT}
EOF

if [ ! -z "${AWS_ACCESS_KEY_ID}" ]; then
    cat <<EOF >${AWS_SHARED_CREDENTIALS_FILE}
[${AWS_PROFILE}]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
fi

exec "$@"
