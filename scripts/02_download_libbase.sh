#!/bin/bash

git clone https://android.googlesource.com/platform/system/libbase --single-branch --branch platform-tools-34.0.0 src/depends/libbase
rm -rf src/depends/libbase/.git

# required headers to compile libbase
mkdir -p src/depends/android/
curl https://android.googlesource.com/platform/system/logging/+/refs/tags/platform-tools-34.0.0/liblog/include/android/log.h?format=text | base64 -d > src/depends/android/log.h
