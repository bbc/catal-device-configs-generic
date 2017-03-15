#!/bin/bash

# Required command line arguments
COMMIT_HASH=$1
ENVIRONMENT=$2

echo "Deploying configs version $COMMIT_HASH to $ENVIRONMENT"

# Project specific
CONFIG_FILENAME="app-configs-version.json"
CONFIG_PROJECT="catal"
CONFIG_RELEASEPATH="catal-app-configs"

validateTarget(){
 RELEASEPATH=$1
 COMMIT_HASH=$2
 PROJECT=$3
 echo "Validating that $PROJECT device config target [$COMMIT_HASH] is available"
 targetDetails=`aws s3 ls s3://connected-tv-private-unversioned/$RELEASEPATH/$COMMIT_HASH/`
 if [[ "$targetDetails" == "" ]]
 then
   echo "*** Invalid $PROJECT device config target $COMMIT_HASH ***"
   echo "Possible valid targets are: "
   for tag in `aws s3 ls s3://connected-tv-private-unversioned/$RELEASEPATH/ | grep PRE | sed "s/^.*PRE \(.*\)\/$/\1/g"`
   do
      echo $tag;
   done
   exit 1
 else
   echo "$PROJECT device config target [$COMMIT_HASH] is valid"
 fi
}

validateTarget "$CONFIG_RELEASEPATH" "$COMMIT_HASH" "$CONFIG_PROJECT"

# Create the version manifest file.
DATETIME=date "%Y-%m-%d %H.%M.%S"
cat > $WORKSPACE/$CONFIG_FILENAME << EOL
{
  "version": "$COMMIT_HASH",
  "releaseDate": "$DATETIME"
}
EOL

# Update the INT environment to use new configs.
aws s3 cp $WORKSPACE/$CONFIG_FILENAME s3://connected-tv-private-versioned/$CONFIG_PROJECT/$ENVIRONMENT/$CONFIG_FILENAME

# Write a deployment message
$WORKSPACE/build/updateAuditLog.sh $COMMIT_HASH $ENVIRONMENT 'catal-device-configs'
