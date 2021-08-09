#!/usr/bin/env bash

PKGS="sdkmanager --install"
for a in $PACKAGES; do
    PKGS="$PKGS \"${a}\""
done

sdkmanager --version
yes | sdkmanager --licenses
# echo "Installing packages $PKGS"
# $PKGS
# sdkmanager --install --package_file=/home/mobiledev/sdk-packages.txt
