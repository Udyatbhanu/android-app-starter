#!/bin/bash

# Usage: ./setup.sh com.new.package NewAppName

OLD_PACKAGE="com.bhanu.baliyar.appstarter"
NEW_PACKAGE="$1"
APP_NAME="$2"

echo "🛠️  Setting up AppStarter..."
echo "📦 Old package: $OLD_PACKAGE"
echo "📦 New package: $NEW_PACKAGE"
echo "📝 New app name: $APP_NAME"

OLD_PACKAGE_DIR=$(echo "$OLD_PACKAGE" | tr '.' '/')
NEW_PACKAGE_DIR=$(echo "$NEW_PACKAGE" | tr '.' '/')

# 1. Rename root project in settings.gradle.kts
sed -i '' "s/rootProject.name = \".*\"/rootProject.name = \"$APP_NAME\"/" settings.gradle.kts

# 2. Replace package name in all relevant files
find . -type f \( -name "*.kt" -o -name "*.xml" -o -name "*.gradle.kts" \) \
    -exec sed -i '' "s/$OLD_PACKAGE/$NEW_PACKAGE/g" {} +

# 3. Move source files to new package directory
SRC_DIR="app/src/main/kotlin/$OLD_PACKAGE_DIR"
DST_DIR="app/src/main/kotlin/$NEW_PACKAGE_DIR"

mkdir -p "$DST_DIR"
cp -r "$SRC_DIR/"* "$DST_DIR"
rm -rf "app/src/main/kotlin/$(echo "$OLD_PACKAGE" | cut -d '.' -f1)"

echo "✅ Project is ready!"