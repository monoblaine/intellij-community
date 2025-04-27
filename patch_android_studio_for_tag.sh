#!/bin/bash

# https://plugins.jetbrains.com/docs/intellij/android-studio-releases-list.html
#
# Android Studio Meerkat 2024.3.1 Patch 2
#
# IntelliJ IDEA Version:
# 2024.3.3
# 243.24978.46

target_tag=$1

if [ -z "$target_tag" ]; then
    echo '"target tag" argument (e.g. idea/243.24978.46) is required.'
    exit 1
fi

git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd android &&
git fetch origin refs/tags/$target_tag:refs/tags/$target_tag &&
cd .. &&
./patch_android_studio.sh
