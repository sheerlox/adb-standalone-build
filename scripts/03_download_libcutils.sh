#!/bin/bash

TMP_DIR=$(mktemp -dq)
if [ $? -ne 0 ]; then
    echo "$0: Can't create temp file, bye.."
    exit 1
fi

cd $TMP_DIR
git init
git remote add origin https://android.googlesource.com/platform/system/core
git sparse-checkout init
git sparse-checkout set libcutils
git pull origin platform-tools-34.0.0

cd -
cp -R $TMP_DIR/libcutils/ ./src/depends/
rm -rf $TMP_DIR
