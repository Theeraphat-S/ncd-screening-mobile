#!/bin/bash

# อ่าน version จาก pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)

# ตรวจสอบว่าได้ version หรือไม่
if [ -z "$VERSION" ]; then
    echo "get version from pubspec.yaml please check file"
    exit 1
fi

# fvm ใช้เวอร์ชัน Flutter ตาม .fvmrc

# build iOS (ipa) — ไม่ใส่ flavor
fvm flutter build ipa --release --dart-define=flavor=dev

BUILD_STATUS=$?

# ตรวจสอบผลลัพธ์
if [ $BUILD_STATUS -eq 0 ]; then
    # Path output ของ Flutter ipa
    OUTPUT_DIR="build/ios/ipa/dev"
    mkdir -p "$OUTPUT_DIR"
    
    # ตั้งชื่อไฟล์ ipa ใหม่
    mv "$OUTPUT_DIR/Runner.ipa" "$OUTPUT_DIR/ncd_screening-${VERSION}.ipa"

    echo "<| Build Success => $OUTPUT_DIR/ncd_screening-${VERSION}.ipa |>"
else
    echo "<| build IPA failed |>"
    exit 1
fi
