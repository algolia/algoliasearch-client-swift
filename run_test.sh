#!/bin/bash

set -e
set -o pipefail

FILE=Tests/Helpers.swift

if [[ $IOS = "TRUE" ]]; then
    echo "Run iOS test..."
    cp $FILE $FILE.bak

    echo "Replace env variable..."
    sed -i.tmp "s/APP_ID_REPLACE_ME/${ALGOLIA_APPLICATION_ID}/g" $FILE
    sed -i.tmp "s/API_KEY_REPLACE_ME/${ALGOLIA_API_KEY}/g" $FILE

    if ! [[ $TRAVIS_JOB_NUMBER && ${TRAVIS_JOB_NUMBER-_} ]]; then
        echo "/!\ TRAVIS_JOB_NUMBER is not set."
        TRAVIS_JOB_NUMBER=$RANDOM.$RANDOM
    fi
    sed -i.tmp "s/JOB_NUMBER_REPLACE_ME/${TRAVIS_JOB_NUMBER}/g" $FILE

    xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch iOS" \
        -sdk "$SDK" -destination "$VERSION" test | xcpretty -c

    mv $FILE.bak $FILE
    rm $FILE.tmp
else
    echo "Run OS X test..."
    xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch OSX" \
        test | xcpretty -c
fi
