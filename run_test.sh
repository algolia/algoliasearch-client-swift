#!/bin/bash

FILE=Tests/Helpers.swift

if [[ $IOS = "TRUE" ]]; then
    echo "Run iOS test..."

    echo "Replace env variable..."
    sed -ie "s/APP_ID_REPLACE_ME/${ALGOLIA_APPLICATION_ID}/g" $FILE
    sed -ie "s/API_KEY_REPLACE_ME/${ALGOLIA_API_KEY}/g" $FILE
    sed -ie "s/JOB_NUMBER_REPLACE_ME/${TRAVIS_JOB_NUMBER}/g" $FILE

    return xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch iOS" \
        -sdk "$SDK" -destination "$VERSION" test | xcpretty -c
else
    echo "Run OS X test..."
    return xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch OSX" \
        test | xcpretty -c
fi
