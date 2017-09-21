#!/bin/bash

set -e
set -o pipefail

FILE=../Tests/Helpers.swift
mv $FILE.bak $FILE
rm $FILE.tmp
