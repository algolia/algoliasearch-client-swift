#!/usr/bin/env ksh
# ============================================================================ #
# DEPLOY
# ============================================================================ #
# SUMMARY
# -------
# Deploys algoliasearch.framework to a public location on Amazon S3.
#
# INPUT
# -----
# - The freshly built packages.
# ============================================================================ #

FRAMEWORK_BASENAME="AlgoliaSearch"
FRAMEWORK_NAME="$FRAMEWORK_BASENAME.framework"
DEPLOY_BASENAME="AlgoliaSearch"
DEPLOY_NAME="$DEPLOY_BASENAME"

SELF_ROOT=`cd \`dirname "$0"\`; pwd`

BUCKET_NAME="alg-binaries"
DIST_OUT="$SELF_ROOT/Carthage/Build/iOS"

# TODO: Carthage build
# -------------------

# TODO: Need to build for all flavors mac os etc so need more folders, also add the online and offline flavor

# Retrieve version number from property list.

VERSION_NO=`$SELF_ROOT/get-version.sh`
echo "Version: $VERSION_NO"

# TODO Add a zip step here

MAIN_PACKAGE_BASENAME="$DEPLOY_NAME"
MAIN_PACKAGE_NAME="$MAIN_PACKAGE_BASENAME.framework.zip"

# AWS config
# if [[ -n $AWS_PROFILE ]]; then
#     AWS_S3_CMD="aws s3 --profile $AWS_PROFILE"
# else
AWS_S3_CMD="aws s3"
# fi

# Deploy to Amazon S3
# -------------------

echo "Deploying to Amazon S3:"
# Upload the main package and make it public.
echo "- Main package"
DST_S3_DIR="s3://$BUCKET_NAME/$DEPLOY_NAME/$VERSION_NO"
$AWS_S3_CMD cp \
"$DIST_OUT/$MAIN_PACKAGE_NAME" "$DST_S3_DIR/$MAIN_PACKAGE_NAME" \
--grants "read=uri=http://acs.amazonaws.com/groups/global/AllUsers"

# List the destination to make sure everything is fine.
echo "Contents of '$DST_S3_DIR':"
$AWS_S3_CMD ls "$DST_S3_DIR/"
