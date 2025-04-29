#!/bin/bash

path_to_product="C:/Program Files/Android/Android Studio"

net session >/dev/null 2>&1
error_level=$?

if [[ $error_level -ne 0 ]]; then
    echo Please run MSYS2 as administrator.
    exit 1
fi

if [ -f "./.tmp/app.jar.orig" ]; then
    echo "./.tmp/app.jar.orig file already exists. Please delete or move it to somewhere else."
    exit 1
fi

jar () {
    "C:/Program Files/Java/jdk-17/bin/jar.exe" "$@"
}

echo -e "
1. Open project in Android Studio
2. cherry-pick the commits
3. Assemble the modules intellij.platform.ide.impl and intellij.platform.lang.impl
4. Close Android Studio
5. Press any key to continue" &&
read -p "waiting..." &&
if [ -d "./.tmp" ]; then
    rm -rf ./.tmp
fi &&
mkdir -p ./.tmp/unzipped &&
echo "*" >./.tmp/.gitignore &&
echo "Creating a copy of app.jar..." &&
cp "$path_to_product/lib/app.jar" ./.tmp/app.jar.orig &&
cd ./.tmp/unzipped &&
echo "Unzipping app.jar..." &&
jar -xf ../app.jar.orig &&
cd - >/dev/null &&
echo "Copying modified class files..." &&
cp "out/production/intellij.platform.ide.impl/com/intellij/ide/util/EditorGotoLineNumberDialog.class" \
   ".tmp/unzipped/com/intellij/ide/util/EditorGotoLineNumberDialog.class" &&
cp "out/production/intellij.platform.ide.impl/com/intellij/ide/actions/EditSourceInNewWindowAction.class" \
   ".tmp/unzipped/com/intellij/ide/actions/EditSourceInNewWindowAction.class" &&
cp 'out/production/intellij.platform.ide.impl/com/intellij/ide/actions/Switcher$SwitcherPanel.class' \
   '.tmp/unzipped/com/intellij/ide/actions/Switcher$SwitcherPanel.class' &&
cp "out/production/intellij.platform.lang.impl/com/intellij/codeInsight/highlighting/BraceHighlightingHandler.class" \
   ".tmp/unzipped/com/intellij/codeInsight/highlighting/BraceHighlightingHandler.class" &&
cd ./.tmp/unzipped &&
if [ -f ../app.jar ]; then
   rm ../app.jar
fi &&
echo "Creating the new app.jar..." &&
jar -cf0 ../app.jar * &&
echo "Moving the new app.jar to installation dir..." &&
mv ../app.jar "$path_to_product/lib/app.jar" &&
cd - >/dev/null &&
echo "Cleaning up..." &&
rm -rf ./.tmp/unzipped
