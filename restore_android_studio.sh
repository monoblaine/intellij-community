#!/bin/bash

path_to_product="C:/Program Files/Android/Android Studio"

net session >/dev/null 2>&1
error_level=$?

if [[ $error_level -ne 0 ]]; then
    echo Please run MSYS2 as administrator.
    exit 1
fi

cp .tmp/app.jar.orig "$path_to_product/lib/app.jar"
