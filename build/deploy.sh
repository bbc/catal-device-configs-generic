#!/bin/bash

cd $WORKSPACE
# Build the configs into compiled directory
npm install && npm run build
if [ $? != 0 ]; then
    exit 1
fi

# Grab the short commit hash
export COMMIT_HASH=$(git log --pretty=format:'%h' -n 1)

# Create a buildstamp.json file with helpful debugging information.
cat > $WORKSPACE/buildstamp.json << EOL
{
  "date": "`date`",
  "build_number": "$BUILD_NUMBER",
  "git_commit": "$GIT_COMMIT",
  "commit_hash": "$COMMIT_HASH"
}
EOL

S3PATH=s3://connected-tv-private-unversioned/catal-app-configs

# Keep a record of buildstamp.json in CI job output.
cat $WORKSPACE/buildstamp.json

# Prevent an existing release from being overwritten
count=`aws s3 ls $S3PATH/${COMMIT_HASH}/buildstamp.json | wc -l`
if [[ $count -gt 0 ]]; then
    echo "Released folder already exists, aborting."
    exit 1
else
    echo "Released folder does not not exist, continuing:"

    # Write buildstamp.json alongside configs in S3.
    aws s3 cp $WORKSPACE/buildstamp.json $S3PATH/${COMMIT_HASH}/buildstamp.json

    # Publish configs to S3.
    aws s3 sync $WORKSPACE/compiled $S3PATH/${COMMIT_HASH}/

    $WORKSPACE/build/deployToEnv.sh $COMMIT_HASH int
fi
