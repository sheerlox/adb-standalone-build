#!/bin/bash
# Script to get protobuf version used by a specific a platform tools version
# Copyright (C) 2023 Pierre Cavin (me@sherlox.io)
# Permission to copy and modify is granted under the GNU GPLv3 license
set -e

if [ $# -ne 1 ] ; then
    echo 'Usage: ./utils/get_protobuf_version.sh <platform_tools_version>'
    exit 1
fi
PLATFORM_TOOLS_REF=platform-tools-$1

TMP_DIR=$(mktemp -dq)
if [ $? -ne 0 ]; then
    echo "$0: Can't create temp file, bye.."
    exit 1
fi

git clone https://android.googlesource.com/platform/external/protobuf --single-branch --branch $PLATFORM_TOOLS_REF --depth 1 $TMP_DIR >/dev/null 2>&1

awk -F',' '/AC_INIT\(\[Protocol Buffers\],/ { gsub(/(\[|\])/,""); print $2; }' $TMP_DIR/configure.ac

rm -rf $TMP_DIR
