#!/usr/bin/env ksh

set -e -o pipefail

# Reflection.
SELF_NAME=`basename "$0"`
SELF_ROOT=`cd \`dirname "$0"\`; pwd`

# Extract the module's version number from the Xcode project `Info.plist`.
plutil -extract CFBundleShortVersionString xml1 -o - "$SELF_ROOT/../Source/Info.plist" \
| grep "<string>" \
| sed -E 's|</?string>||g'