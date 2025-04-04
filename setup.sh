#!/bin/bash

# Usage: ./setup.sh com.new.package NewAppName

OLD_PACKAGE="com.bhanu.baliyar.appstarter"
NEW_PACKAGE="${1:?❌ Please provide a new package name (e.g. com.example.myapp)}"
APP_NAME="${2:?❌ Please provide a new app name (e.g. MyApp)}"

echo "🛠️  Setting up AppStarter..."
echo "📦 Old package: $OLD_PACKAGE"
echo "📦 New package: $NEW_PACKAGE"
echo "📝 New app name: $APP_NAME"

OLD_PACKAGE_DIR="$(echo "${OLD_PACKAGE:?}" | tr '.' '/')"
NEW_PACKAGE_DIR="$(echo "${NEW_PACKAGE:?}" | tr '.' '/')"

SRC_ROOT="app/src/main/java"
SRC_DIR="${SRC_ROOT:?}/${OLD_PACKAGE_DIR:?}"
DST_DIR="${SRC_ROOT:?}/${NEW_PACKAGE_DIR:?}"

# ✅ Safety check: prevent operating on root
if [[ "$DST_DIR" == "/" || "$DST_DIR" == "." || -z "$DST_DIR" ]]; then
  echo "❌ Unsafe or empty DST_DIR: '$DST_DIR'. Aborting."
  exit 1
fi

# 1. Rename root project name in settings.gradle.kts
sed -i '' "s/rootProject.name = \".*\"/rootProject.name = \"$APP_NAME\"/" settings.gradle.kts

# 2. Replace old package with new in all relevant files
find . -type f \( -name "*.kt" -o -name "*.xml" -o -name "*.gradle.kts" \) \
    -exec sed -i '' "s/${OLD_PACKAGE:?}/${NEW_PACKAGE:?}/g" {} +

# 3. Update or insert manifest package attribute
find . -type f -name "AndroidManifest.xml" | while read -r manifest; do
    if grep -q "package=" "$manifest"; then
        sed -i '' "s/package=\"${OLD_PACKAGE:?}\"/package=\"${NEW_PACKAGE:?}\"/g" "$manifest"
    else
        sed -i '' "s|<manifest |<manifest package=\"${NEW_PACKAGE:?}\" |" "$manifest"
    fi
done

# 4. Move source files to new package path
mkdir -p "${DST_DIR:?}"
cp -r "${SRC_DIR:?}/"* "${DST_DIR:?}"

# 5. Remove old top-level package dir safely
TOP_PACKAGE_DIR="${SRC_ROOT:?}/$(echo "${OLD_PACKAGE:?}" | cut -d '.' -f1)"
rm -rf "${TOP_PACKAGE_DIR:?}"

echo "✅ Setup complete!"
echo "📦 Package updated to: $NEW_PACKAGE"
echo "📁 Source files moved to: $DST_DIR"