#!/bin/bash
SOURCE_ENV=test
TARGET_ENV=live

aws s3 sync s3://connected-tv-private-versioned/catal/$SOURCE_ENV/ s3://connected-tv-private-versioned/catal/$TARGET_ENV/
aws s3 sync s3://connected-tv-private-versioned/tal/$SOURCE_ENV/ s3://connected-tv-private-versioned/tal/$TARGET_ENV/

# Write a deployment message
CATAL_COMMIT_HASH='unknown'
TAL_COMMIT_HASH='unknown'
$WORKSPACE/build/updateAuditLog.sh $CATAL_COMMIT_HASH $TARGET_ENV catal-device-configs
$WORKSPACE/build/updateAuditLog.sh $TAL_COMMIT_HASH $TARGET_ENV tal-device-configs
