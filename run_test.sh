#!/bin/bash

set -e
set -o pipefail

FILE=Tests/Helpers.swift

if ! [[ $TRAVIS_JOB_NUMBER && ${TRAVIS_JOB_NUMBER-_} ]]; then
    echo "/!\ TRAVIS_JOB_NUMBER is not set."
    TRAVIS_JOB_NUMBER=$RANDOM.$RANDOM
fi

# Unit tests rely on Cocoapods.
# If you wonder why, see `Podfile` for a discussion.
pod --version
pod install

if [[ $IOS = "TRUE" ]]; then
    echo "Run iOS test..."
    cp $FILE $FILE.bak

    # Environment variables are not available from the iOS Simulator, so we patch a source file instead.
    echo "Replace env variable..."
    sed -i.tmp "s/APP_ID_REPLACE_ME/${ALGOLIA_APPLICATION_ID}/g" $FILE
    sed -i.tmp "s/API_KEY_REPLACE_ME/${ALGOLIA_API_KEY}/g" $FILE
    sed -i.tmp "s/JOB_NUMBER_REPLACE_ME/${TRAVIS_JOB_NUMBER}/g" $FILE

    xcodebuild -workspace AlgoliaSearch.xcworkspace -scheme "AlgoliaSearch-iOS-Tests" \
        -sdk "$SDK" -destination "$VERSION" test

    mv $FILE.bak $FILE
    rm $FILE.tmp
else
    echo "Run OS X test..."
    xcodebuild -workspace AlgoliaSearch.xcworkspace -scheme "AlgoliaSearch-OSX-Tests" \
        test
fi
