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
3. Assemble the following modules:
    * intellij.platform.lang.impl
    * intellij.platform.ide
    * intellij.platform.ide.impl
    * intellij.platform.recentFiles.frontend
4. Close Android Studio
5. Press any key to continue" &&
read -p "waiting..." &&
if [ -d "./.tmp" ]; then
    rm -rf ./.tmp
fi &&
mkdir ./.tmp &&
echo "*" >./.tmp/.gitignore &&

# ==============================================================================
# app.jar
# ==============================================================================
mkdir -p ./.tmp/unzipped &&
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
cp 'out/production/intellij.platform.lang.impl/com/intellij/find/EditorSearchSession$ReplaceAction.class' \
   '.tmp/unzipped/com/intellij/find/EditorSearchSession$ReplaceAction.class' &&
cp "out/production/intellij.platform.ide.impl/com/intellij/ui/popup/AbstractPopup.class" \
   ".tmp/unzipped/com/intellij/ui/popup/AbstractPopup.class" &&
cp "out/production/intellij.platform.ide.impl/com/intellij/openapi/fileEditor/impl/tabActions/CloseTab.class" \
   ".tmp/unzipped/com/intellij/openapi/fileEditor/impl/tabActions/CloseTab.class" &&
cp "out/production/intellij.platform.ide.impl/com/intellij/openapi/fileEditor/impl/tabActions/DotIcon.class" \
   ".tmp/unzipped/com/intellij/openapi/fileEditor/impl/tabActions/DotIcon.class" &&
cp 'out/production/intellij.platform.ide/com/intellij/ui/tabs/impl/JBTabsImpl$DefaultDecorator.class' \
   '.tmp/unzipped/com/intellij/ui/tabs/impl/JBTabsImpl$DefaultDecorator.class' &&
cp 'out/production/intellij.platform.ide/com/intellij/ui/tabs/impl/TabLabel.class' \
   '.tmp/unzipped/com/intellij/ui/tabs/impl/TabLabel.class' &&
cp 'out/production/intellij.platform.ide/com/intellij/ui/tabs/impl/JBDefaultTabPainter.class' \
   '.tmp/unzipped/com/intellij/ui/tabs/impl/JBDefaultTabPainter.class' &&
cp "out/production/intellij.platform.analysis.impl/messages/FindBundle.properties" \
   ".tmp/unzipped/messages/FindBundle.properties" &&
cp "out/production/intellij.platform.ide/messages/EditorBundle.properties" \
   ".tmp/unzipped/messages/EditorBundle.properties" &&
cd ./.tmp/unzipped &&
if [ -f ../app.jar ]; then
   rm ../app.jar
fi &&
echo "Creating the new app.jar..." &&
jar -cf0 ../app.jar * &&
echo "Moving the new app.jar to installation dir..." &&
mv ../app.jar "$path_to_product/lib/app.jar" &&
cd - >/dev/null &&
rm -rf ./.tmp/unzipped &&

# ==============================================================================
# intellij.platform.recentFiles.frontend.jar
# ==============================================================================
mkdir -p ./.tmp/unzipped &&
echo "Creating a copy of intellij.platform.recentFiles.frontend.jar..." &&
cp "$path_to_product/lib/modules/intellij.platform.recentFiles.frontend.jar" ./.tmp/intellij.platform.recentFiles.frontend.jar.orig &&
cd ./.tmp/unzipped &&
echo "Unzipping intellij.platform.recentFiles.frontend.jar..." &&
jar -xf ../intellij.platform.recentFiles.frontend.jar.orig &&
cd - >/dev/null &&
echo "Copying modified class files..." &&
cp out/production/intellij.platform.recentFiles.frontend/com/intellij/platform/recentFiles/frontend/*.class \
   ./.tmp/unzipped/com/intellij/platform/recentFiles/frontend/ &&
cd ./.tmp/unzipped &&
if [ -f ../intellij.platform.recentFiles.frontend.jar ]; then
   rm ../intellij.platform.recentFiles.frontend.jar
fi &&
echo "Creating the new intellij.platform.recentFiles.frontend.jar..." &&
jar -cf0 ../intellij.platform.recentFiles.frontend.jar * &&
echo "Moving the new intellij.platform.recentFiles.frontend.jar to installation dir..." &&
mv ../intellij.platform.recentFiles.frontend.jar "$path_to_product/lib/modules/intellij.platform.recentFiles.frontend.jar" &&
cd - >/dev/null &&

echo "Cleaning up..." &&
rm -rf ./.tmp/unzipped
