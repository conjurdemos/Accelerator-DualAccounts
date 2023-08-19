#!/bin/bash

# Automated export of all platforms of systemType Database

source ./env-vars.sh

# Get all Platform Ids of systemType Database
PLATFORM_IDS=$(./cybrvault-cli.sh platforms_get | jq -r '.Platforms[] | select(.general.systemType=="Database").general.id')

for platId in $PLATFORM_IDS; do
  echo "Exporting $platId..."
  ./cybrvault-cli.sh platform_export $platId ./exported_zipfiles/$platId.zip
done

exit

####################################
# Other useful queries

# Get all Platform Names
#./cybrvault-cli.sh platforms_get | jq -r '.Platforms[].general.name'

# Get all Platform systemTypes 
#./cybrvault-cli.sh platforms_get | jq -r '[.Platforms[].general.systemType] | unique | .[]'
			# jq explainer: put all systemTypes in array, uniqueify, return elements of uniqueified array
