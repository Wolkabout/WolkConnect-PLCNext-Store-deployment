#!/usr/bin/env bash
<<COMMENT
This is script for making .app on the native platform AXCF2152 PLC device
COMMENT
# Make the script terminate if it fails
set -e
# Set constants
Username="admin"
ProjectName="WolkConnect-PLCNext-Store-deployment"
DestinationDirectory="/opt/plcnext"
AppName="WolkConnect-PLCNext"

# Check if there's sshpass
if ! command -v sshpass &>/dev/null; then
  echo "Required command 'sshpass' is missing. Please install 'sshpass' and re-run the script."
  exit
fi

# Enter the SSH address
if [[ -z $1 ]]; then
	  while [[ ! $IpAddress =~ ([1-2]?[0-9]?[0-9]\.){3}([1-2]?[0-9]?[0-9]) ]]; do
		      read -rp "Enter the SSH address: " IpAddress
		        done
		else
			  IpAddress=$1
fi

#Insert the SSH credentials
if [[ -z $2 ]]; then
	  Username="admin"
	    read -rp "Enter the Username: " -e -i $Username Username
    else
	      Username=$2
fi

if [[ -z $3 ]]; then
	  read -srp "Enter the Password: " Password
	    echo ""
    else
	      Password=$3
fi
echo ${IpAddress} ${Username} ${Password}

# Prepare build artifacts
rsync -a --exclude='output' ../../${ProjectName} .
# Copy installation artifacts to PLC
echo "Transfer installation artifacts"
sshpass -p "${Password}" scp -r ${ProjectName} "${Username}"@"${IpAddress}:${DestinationDirectory}"
# Remove build artifacts
rm -rf ${ProjectName}

echo "Start building application"
sshpass -p "${Password}" ssh -q "${Username}"@"${IpAddress}" "plcnextapp create ${ProjectName} ${AppName}"

echo "Copy application from build machine into output/ dir"
sshpass -p "${Password}" scp -q -r "${Username}"@"${IpAddress}:${DestinationDirectory}/${AppName}.app" "../output"

echo "Remove build artifacts from destination"
sshpass -p "${Password}" ssh "${Username}"@"${IpAddress}" "rm -rf ${AppName}*"

echo "Build is done!"
