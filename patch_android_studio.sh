#!/bin/bash

echo -e '
version=<new intellij version>
git_tag='"'"'idea/'"'"'"$version"
./fetch_tag.sh "$git_tag"
git checkout -b enhancements@$git_tag $git_tag
cd android && git reset --hard $git_tag && cd ..

 1. [ ] cherry-pick the commits
 2. [ ] `rm -rf out/*`
 3. [ ] Check build configuration section in https://github.com/JetBrains/intellij-community/tree/idea/<version>
 4. [ ] Open project in Android Studio
 5. Assemble the following modules:
     * [ ] `intellij.platform.analysis.impl`
     * [ ] `intellij.platform.lang.impl`
     * [ ] `intellij.platform.ide`
     * [ ] `intellij.platform.ide.impl`
     * [ ] `intellij.platform.recentFiles.frontend`
 6. [ ] Close Android Studio
 7. [ ] `./restore_android_studio.sh <existing intellij version>`
 8. [ ] Open Android Studio and run the updater
 9. [ ] Close Android Studio
10. [ ] `./patch_android_studio.sh <new intellij version>`
11. [ ] `git push -u fork enhancements@idea/<new intellij version>`'
read -p "Press any key to continue..."

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
path_to_ver=$(abs_path "./.bak/$version") &&
path_to_original="$path_to_ver/original" &&
path_to_patched="$path_to_ver/patched" &&
path_to_tmp=$(abs_path "./.tmp") &&
path_to_unzipped="$path_to_tmp/unzipped" &&
path_to_out=$(abs_path "./out/production") &&

mkdir -p "$path_to_original" &&
mkdir -p "$path_to_patched" &&

if [ -z "$(find "$path_to_original" -maxdepth 0 -empty)" ]; then
    echo "Directory ($path_to_original) is not empty, aborting."
    exit 1
fi

jar () {
    "$program_files/Java/jdk-17/bin/jar.exe" "$@"
}

init_jar_stuff () {
    jar_name=$1 &&
    relative_path_to_origin_jar=$2 &&
    mkdir -p "$path_to_unzipped" &&
    origin_jar="$path_to_product/$relative_path_to_origin_jar/$jar_name" &&
    backup_jar="$path_to_original/$jar_name" &&
    patched_jar="$path_to_patched/$jar_name" &&
    cp -v "$origin_jar" "$backup_jar" &&
    cd "$path_to_unzipped" &&
    echo "Unzipping $jar_name..." &&
    jar -xf "$backup_jar" &&
    cd - >/dev/null &&
    echo "Copying modified class files..." &&
    cd "$path_to_out"
}

cp_cls () {
    arr=("$@") &&
    dest=${arr[-1]} &&
    unset arr[-1] &&
    cp -v "${arr[@]}" "$path_to_unzipped/$dest"
}

finalize_jar_stuff () {
    is_last_task=${1:-0} &&
    cd - >/dev/null &&
    cd "$path_to_unzipped" &&
    if [ -f "$patched_jar" ]; then
       rm -v "$patched_jar"
    fi &&
    echo "Creating the new $jar_name..." &&
    jar -cf0 "$patched_jar" '*' &&
    cp -v "$patched_jar" "$origin_jar" &&
    cd - >/dev/null &&
    if [[ "$is_last_task" == "1" ]]; then
        echo "Cleaning up..."
    fi &&
    rm -rf "$path_to_unzipped"
}

if [ -d "$path_to_tmp" ]; then
    rm -rf "$path_to_tmp"
fi &&
mkdir -p "$path_to_tmp" &&

# ==============================================================================
# app.jar
# ==============================================================================
init_jar_stuff "app.jar" "lib" &&
# intellij.platform.analysis.impl
cp_cls 'intellij.platform.analysis.impl/messages/FindBundle.properties' \
       'messages/FindBundle.properties' &&
# intellij.platform.lang.impl
cp_cls 'intellij.platform.lang.impl/com/intellij/codeInsight/highlighting/BraceHighlightingHandler.class' \
       'com/intellij/codeInsight/highlighting/BraceHighlightingHandler.class' &&
cp_cls 'intellij.platform.lang.impl/com/intellij/find/EditorSearchSession$ReplaceAction.class' \
       'com/intellij/find/EditorSearchSession$ReplaceAction.class' &&
# intellij.platform.ide
cp_cls 'intellij.platform.ide/com/intellij/ui/tabs/impl/JBTabsImpl$DefaultDecorator.class' \
       'com/intellij/ui/tabs/impl/JBTabsImpl$DefaultDecorator.class' &&
cp_cls 'intellij.platform.ide/com/intellij/ui/tabs/impl/TabLabel.class' \
       'com/intellij/ui/tabs/impl/TabLabel.class' &&
cp_cls 'intellij.platform.ide/com/intellij/ui/tabs/impl/JBDefaultTabPainter.class' \
       'com/intellij/ui/tabs/impl/JBDefaultTabPainter.class' &&
cp_cls 'intellij.platform.ide/messages/EditorBundle.properties' \
       'messages/EditorBundle.properties' &&
# intellij.platform.ide.impl
cp_cls 'intellij.platform.ide.impl/com/intellij/ide/util/EditorGotoLineNumberDialog.class' \
       'com/intellij/ide/util/EditorGotoLineNumberDialog.class' &&
cp_cls 'intellij.platform.ide.impl/com/intellij/ide/actions/EditSourceInNewWindowAction.class' \
       'com/intellij/ide/actions/EditSourceInNewWindowAction.class' &&
cp_cls 'intellij.platform.ide.impl/com/intellij/ide/actions/Switcher$SwitcherPanel.class' \
       'com/intellij/ide/actions/Switcher$SwitcherPanel.class' &&
cp_cls 'intellij.platform.ide.impl/com/intellij/ui/popup/AbstractPopup.class' \
       'com/intellij/ui/popup/AbstractPopup.class' &&
cp_cls 'intellij.platform.ide.impl/com/intellij/openapi/fileEditor/impl/tabActions/CloseTab.class' \
       'com/intellij/openapi/fileEditor/impl/tabActions/CloseTab.class' &&
cp_cls 'intellij.platform.ide.impl/com/intellij/openapi/fileEditor/impl/tabActions/DotIcon.class' \
       'com/intellij/openapi/fileEditor/impl/tabActions/DotIcon.class' &&
finalize_jar_stuff &&
# ==============================================================================
# intellij.platform.recentFiles.frontend.jar
# ==============================================================================
init_jar_stuff "intellij.platform.recentFiles.frontend.jar" "lib/modules" &&
# intellij.platform.recentFiles.frontend
cp_cls intellij.platform.recentFiles.frontend/com/intellij/platform/recentFiles/frontend/*.class \
       'com/intellij/platform/recentFiles/frontend/' &&
finalize_jar_stuff 1
