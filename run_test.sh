#!/bin/bash

set -e
set -o pipefail

FILE=Tests/Helpers.swift

# Check environment variables.
if [[ -z $PLATFORM ]]; then
    echo "Please specify the platform" 1>&2
    exit 1
fi
if [[ -z $SDK ]]; then
    echo "Please specify the SDK" 1>&2
    exit 1
fi
if ! [[ $TRAVIS_JOB_NUMBER && ${TRAVIS_JOB_NUMBER-_} ]]; then
    echo "/!\ TRAVIS_JOB_NUMBER is not set."
    TRAVIS_JOB_NUMBER=$RANDOM.$RANDOM
fi

# On platforms other than OS X, the tests run inside a simulator, so environment variables are not available;
# let's patch the source file instead.
if [[ "$PLATFORM" != "OSX" ]]; then
    cp $FILE $FILE.bak

    echo "Replace environment variables..."
    sed -i.tmp "s/%ALGOLIA_APPLICATION_ID%/${ALGOLIA_APPLICATION_ID}/g" $FILE
    sed -i.tmp "s/%ALGOLIA_API_KEY%/${ALGOLIA_API_KEY}/g" $FILE
    sed -i.tmp "s/%PLACES_APPLICATION_ID%/${PLACES_APPLICATION_ID}/g" $FILE
    sed -i.tmp "s/%PLACES_API_KEY%/${PLACES_API_KEY}/g" $FILE
    sed -i.tmp "s/JOB_NUMBER_REPLACE_ME/${TRAVIS_JOB_NUMBER}/g" $FILE
fi

# Run tests.
echo "Running tests..."
if [ -n "$DESTINATION" ]; then
    xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch $PLATFORM" -sdk "$SDK" -destination "$DESTINATION" test
else
    xcodebuild -project AlgoliaSearch.xcodeproj -scheme "AlgoliaSearch $PLATFORM" -sdk "$SDK" test
fi

# Clean-up: revert patched file.
if [[ "$PLATFORM" != "OSX" ]]; then
    mv $FILE.bak $FILE
    rm $FILE.tmp
fi
