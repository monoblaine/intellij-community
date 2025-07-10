#!/bin/bash

# https://plugins.jetbrains.com/docs/intellij/android-studio-releases-list.html
#
# IntelliJ IDEA Version:
# 251.26094.121

target_tag=$1

if [ -z "$target_tag" ]; then
    echo '"target tag" argument (e.g. idea/243.24978.46) is required.'
    exit 1
fi

git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd android &&
git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd ..
