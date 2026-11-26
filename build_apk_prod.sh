#!/bin/bash
# Build the prod flavor APK. Release signing uses android/key.properties (see docs/RELEASE.md).

VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)
if [ -z "$VERSION" ]; then
    echo "get version from pubspec.yaml please check file"
    exit 1
fi

fvm flutter build apk --flavor prod || { echo "<| build APK failed |>"; exit 1; }

OUT_DIR=build/app/outputs/flutter-apk/prod
mkdir -p "$OUT_DIR"
mv build/app/outputs/flutter-apk/app-prod-release.apk "$OUT_DIR/ncd_screening-${VERSION}.apk"
echo "<| Build Success => $OUT_DIR/ncd_screening-${VERSION}.apk |>"
