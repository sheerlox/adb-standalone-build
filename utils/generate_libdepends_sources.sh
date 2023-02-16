#!/bin/bash
# Hacky script to list adb header dependencies for Linux.
# It ignores daemon and test files.
# Copyright (C) 2023 Pierre Cavin (me@sherlox.io)
# Permission to copy and modify is granted under the GNU GPLv3 license
set -e

declare -a adb_dependencies_arr

cd src/

SOURCE_FILES=$(find adb/ -not -path "adb/daemon/*" -not -path "*/tests/*" -not -path "*_test.cpp" -not -path "*_windows.cpp" -not -path "*_osx.cpp" -type f -name "*.cpp")

for source_file in $SOURCE_FILES
do
  source_file_header_deps=$(awk '/^#include <.*?\//{ gsub(/(<|>)/,""); print "depends/"$2 }' $source_file)
  source_file_source_deps=${source_file_header_deps//.h/.???}
  adb_dependencies_arr=(${adb_dependencies_arr[@]} $source_file_source_deps)
done

IFS=$'\n'
sorted_adb_dependencies_arr=($(sort --uniq <<<"${adb_dependencies_arr[*]}"))
unset IFS
printf '%s \\\n' "${sorted_adb_dependencies_arr[@]}"
