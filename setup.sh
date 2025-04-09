#!/bin/bash

# Usage: ./setup.sh com.new.package NewAppName

OLD_PACKAGE="com.bhanu.baliyar.appstarter"
NEW_PACKAGE="${1:?❌ Please provide a new package name (e.g. com.example.myapp)}"
APP_NAME="${2:?❌ Please provide a new app name (e.g. MyApp)}"

echo "🛠️  Setting up AppStarter..."
echo "📦 Old package: $OLD_PACKAGE"
echo "📦 New package: $NEW_PACKAGE"
echo "📝 New app name: $APP_NAME"

OLD_PACKAGE_DIR="$(echo "$OLD_PACKAGE" | tr '.' '/')"
NEW_PACKAGE_DIR="$(echo "$NEW_PACKAGE" | tr '.' '/')"

SRC_ROOT="app/src/main/java"
SRC_DIR="${SRC_ROOT}/${OLD_PACKAGE_DIR}"
DST_DIR="${SRC_ROOT}/${NEW_PACKAGE_DIR}"

# ✅ Detect sed style (macOS vs Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

# ✅ Safety check: prevent operating on root
if [[ "$DST_DIR" == "/" || "$DST_DIR" == "." || -z "$DST_DIR" ]]; then
  echo "❌ Unsafe or empty DST_DIR: '$DST_DIR'. Aborting."
  exit 1
fi

# ✅ Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "❌ Source package directory not found: $SRC_DIR"
  exit 1
fi

# 1. Rename root project name in settings.gradle.kts
$SED_INPLACE "s/rootProject.name = \".*\"/rootProject.name = \"$APP_NAME\"/" settings.gradle.kts

# 2. Replace old package with new in .kt, .xml, .gradle.kts
find . -type f \( -name "*.kt" -o -name "*.xml" -o -name "*.gradle.kts" \) \
  -exec $SED_INPLACE "s/$OLD_PACKAGE/$NEW_PACKAGE/g" {} +

# 3. Update AndroidManifest package attributes
find . -type f -name "AndroidManifest.xml" | while read -r manifest; do
  if grep -q "package=" "$manifest"; then
    $SED_INPLACE "s/package=\"$OLD_PACKAGE\"/package=\"$NEW_PACKAGE\"/" "$manifest"
  else
    $SED_INPLACE "s|<manifest |<manifest package=\"$NEW_PACKAGE\" |" "$manifest"
  fi
done

# 4. Move Kotlin files to new package
mkdir -p "$DST_DIR"
rsync -a "$SRC_DIR/" "$DST_DIR/"

# 5. Remove old package directory only if safe
echo "🧹 Removing old package: $SRC_DIR"
rm -rf "$SRC_DIR"

echo "✅ Setup complete!"
echo "📦 Package updated to: $NEW_PACKAGE"
echo "📁 Source files moved to: $DST_DIR"
echo "📱 App name set to: $APP_NAME"
echo "🔄 Please sync Gradle and rebuild the project."