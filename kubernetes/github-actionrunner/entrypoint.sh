#!/usr/bin/env zsh
echo "Will configure this container now with hostname $HOSTNAME.."
cd ~
./config.sh --url $REPOURL --token $REPOTOKEN --name $HOSTNAME --work /work --unattended --replace --labels "${LABELS}"

if [ -r "/secrets/maven-settings.xml" ]; then
    echo "Installing maven settings.."
    cp /secrets/maven-settings.xml $HOME/.m2/settings.xml
fi

echo "Running now the cmd.."
eval $@
