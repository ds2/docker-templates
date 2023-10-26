#!/usr/bin/env bash
echo "Will configure this container now with hostname $HOSTNAME.."
cd ~
if [ -z "$DRYRUN" ]; then
    ./config.sh --url $REPOURL --token $REPOTOKEN --name $HOSTNAME --work /work --unattended --replace --labels "${LABELS}" || exit 1
else
    echo "Dryrun enabled! Will not kill container if error!"
    ./config.sh --url $REPOURL --token $REPOTOKEN --name $HOSTNAME --work /work --unattended --replace --labels "${LABELS}"
fi


if [ -r "/secrets/maven-settings.xml" ]; then
    echo "Installing maven settings.."
    cp /secrets/maven-settings.xml $HOME/.m2/settings.xml
fi

echo "Running now the cmd.."
eval "$@"
