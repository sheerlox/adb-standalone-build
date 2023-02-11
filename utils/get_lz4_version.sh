#!/bin/bash
# Script to get lz4 version used by a specific a platform tools version
# Copyright (C) 2023 Pierre Cavin (me@sherlox.io)
# Permission to copy and modify is granted under the GNU GPLv3 license
set -e

if [ $# -ne 1 ] ; then
    echo 'Usage: ./utils/get_lz4_version.sh <platform_tools_version>'
    exit 1
fi
PLATFORM_TOOLS_REF=platform-tools-$1

TMP_DIR=$(mktemp -dq)
if [ $? -ne 0 ]; then
    echo "$0: Can't create temp file, bye.."
    exit 1
fi

git clone https://android.googlesource.com/platform/external/lz4 --single-branch --branch $PLATFORM_TOOLS_REF --depth 1 $TMP_DIR >/dev/null 2>&1

MAJOR=$(awk '/^#define LZ4_VERSION_MAJOR/ { print $3; }' $TMP_DIR/lib/lz4.h)
MINOR=$(awk '/^#define LZ4_VERSION_MINOR/ { print $3; }' $TMP_DIR/lib/lz4.h)
RELEASE=$(awk '/^#define LZ4_VERSION_RELEASE/ { print $3; }' $TMP_DIR/lib/lz4.h)

echo ${MAJOR}.${MINOR}.${RELEASE}

rm -rf $TMP_DIR
