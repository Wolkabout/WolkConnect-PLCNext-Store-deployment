#!/usr/bin/env bash
<<COMMENT
This is script for making .app on the host machine
COMMENT
# Make the script terminate if it fails
set -e
# Set constants
ProjectName="WolkConnect-PLCNext-Store-deployment"
AppName="WolkConnect-PLCNext"

# Prepare build artifacts
rsync -a --exclude='output' --exclude='tools' --exclude='.idea' --exclude='.git' ../../${ProjectName} .
mksquashfs ${ProjectName} ../output/${AppName}.app -force-uid 1001 -force-gid 1002
# Remove build artifacts
rm -rf ${ProjectName}

echo "Build is done!"
