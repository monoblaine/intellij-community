#!/bin/bash

# https://plugins.jetbrains.com/docs/intellij/android-studio-releases-list.html
#
# Android Studio Narwhal | 2025.1.1
#
# Build #AI-251.25410.109.2511.13665796, built on June 18, 2025
# Runtime version: 21.0.6+-13391695-b895.109 amd64
#
# IntelliJ IDEA Version:
# 251.25410.109

target_tag=$1

if [ -z "$target_tag" ]; then
    echo '"target tag" argument (e.g. idea/243.24978.46) is required.'
    exit 1
fi

git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd android &&
git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd ..
