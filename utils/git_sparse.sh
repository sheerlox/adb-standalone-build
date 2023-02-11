#!/bin/bash
# Script to pull a specific directory / file from a git repository
# Copyright (C) 2023 Pierre Cavin (me@sherlox.io)
# Permission to copy and modify is granted under the GNU GPLv3 license
set -e

if [ $# -ne 4 ] ; then
    echo 'Usage: ./utils/git_sparse.sh <repository_url> <ref> <patterns> <relative_dest_dir>'
    exit 1
fi
REPOSITORY=$1
REF=$2
PATTERNS=$3
DESTINATION="$(cd "$(dirname "$4")"; pwd)/$(basename "$4")"

TMP_DIR=$(mktemp -dq)
if [ $? -ne 0 ]; then
    echo "$0: Can't create temp file, bye.."
    exit 1
fi

git clone $REPOSITORY --single-branch --branch $REF --depth 1 $TMP_DIR

cp -R $TMP_DIR/$PATTERNS $DESTINATION
rm -rf $TMP_DIR
