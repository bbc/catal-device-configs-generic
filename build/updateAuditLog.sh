#!/bin/bash

# Required command line arguments
COMMIT_HASH=$1
ENVIRONMENT=$2

# Project specific
PROJECT_NAME=$3
GIT_PROJECT="https://github.com/bbc/$PROJECT_NAME"

# Environment - use local date, and first part of author's email
AUTHOR=`git log -1 --pretty=format:"%an"`
DATETIME=`date +%Y-%m-%d\ %H:%M:%S`

# Create log file
LOGFILE="$DATETIME $PROJECT_NAME $ENVIRONMENT $COMMIT_HASH $AUTHOR.json"
cat > "$WORKSPACE/$LOGFILE" << EOL
{
  "project": "$PROJECT_NAME",
  "version": "$COMMIT_HASH",
  "date": "$DATETIME",
  "author": "$AUTHOR",
  "commit": "$GIT_PROJECT/commit/$COMMIT_HASH",
  "environment": "$ENVIRONMENT",
  "action": "Release $PROJECT_NAME to $ENVIRONMENT"
}
EOL

# Make release info public so that monitoring dashboards can access them
S3_PATH=s3://connected-tv-public-unversioned/releaselog
echo "Copying log file to server: $S3_PATH/$LOGFILE"
aws s3 cp "$WORKSPACE/$LOGFILE" "$S3_PATH/$LOGFILE" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
