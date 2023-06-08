#!/usr/bin/env bash

# Script to set up the PATH var to find the package_cloud gem

GemDir=$(gem env gemdir)
pcWhich=$(gem which 'package_cloud')
# echo "pcWhich is $pcWhich"
pcWhichDir=$(dirname "$pcWhich")
# echo "pcWhich is $pcWhich"
pcWhichDir=$(dirname "$pcWhichDir")
# echo "pcWhich is $pcWhichDir"

export PATH=$PATH:$pcWhichDir/bin

echo "Good luck ;)"
exec "$@"
