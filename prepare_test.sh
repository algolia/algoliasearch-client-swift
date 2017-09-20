#!/bin/bash

set -e
set -o pipefail

FILE=../Tests/Helpers.swift

cp $FILE $FILE.bak
echo "Replace environment variables..."
sed -i.tmp "s/%ALGOLIA_APPLICATION_ID%/${ALGOLIA_APPLICATION_ID}/g" $FILE
sed -i.tmp "s/%ALGOLIA_API_KEY%/${ALGOLIA_API_KEY}/g" $FILE
sed -i.tmp "s/%PLACES_APPLICATION_ID%/${PLACES_APPLICATION_ID}/g" $FILE
sed -i.tmp "s/%PLACES_API_KEY%/${PLACES_API_KEY}/g" $FILE
