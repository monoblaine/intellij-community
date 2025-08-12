#!/bin/bash

net session >/dev/null 2>&1
error_level=$?

if [[ $error_level -ne 0 ]]; then
    echo Please run MSYS2 as administrator.
    exit 1
fi

version=$1

if [ -z "$version" ]; then
    echo '"version" argument (e.g. 251.25410.109.2511.13665796) is required.'
    exit 1
fi

abs_path () {
    cygpath -m "$(realpath "$1")"
}

program_files=$(abs_path "$PROGRAMFILES") &&
path_to_product="$program_files/Android/Android Studio" &&
source_dir="./.bak/$version/original" &&
cp -v "$source_dir/app.jar" "$path_to_product/lib/" &&
cp -v "$source_dir/intellij.platform.recentFiles.frontend.jar" "$path_to_product/lib/modules/"
