# การ build release และ signing

APK ที่จะแจกให้ผู้ใช้นำร่องต้องเซ็นด้วย **upload keystore ของโปรเจกต์** ห้ามใช้ debug key เพราะ:
- debug key เหมือนกันในทุกเครื่องที่ติดตั้ง Flutter SDK ใครก็สร้าง APK ปลอมที่ติดตั้งทับแอปเราได้
- ถ้าเปลี่ยน key ทีหลัง ผู้ใช้ต้องถอนแอปก่อนติดตั้งใหม่ และข้อมูลในเครื่องจะหายไปด้วย

## ตั้งค่าครั้งแรก (ทำครั้งเดียว)

1. สร้าง keystore แล้วเก็บไว้ **นอก repo** (ตั้งรหัสผ่านเอง และสำรองไฟล์ไว้ที่ปลอดภัย ถ้าไฟล์หายจะอัปเดตแอปเดิมไม่ได้อีก)

   ```powershell
   New-Item -ItemType Directory -Force $env:USERPROFILE\keys
   ```

   ```powershell
   keytool -genkey -v -keystore $env:USERPROFILE\keys\ncd-screening-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. คัดลอก `android/key.properties.example` ไปเป็น `android/key.properties` แล้วกรอกค่าให้ครบ ไฟล์นี้อยู่ใน `.gitignore` แล้ว ห้าม commit

## Build

| คำสั่ง | ผลลัพธ์ |
|---|---|
| `./build_apk_dev.sh` | `build/app/outputs/flutter-apk/dev/ncd_screening-alpha-<version>.apk` |
| `./build_apk_prod.sh` | `build/app/outputs/flutter-apk/prod/ncd_screening-<version>.apk` |
| `build_windows_dev.bat` / `build_windows_prod.bat` | `build/NCD-Screening-Windows-*.zip` (เครื่อง Hub) |

ถ้าไม่มี `android/key.properties` Gradle จะเตือนว่า `release build is signed with the DEBUG key` APK ที่ได้ใช้ทดสอบในเครื่องตัวเองได้อย่างเดียว ห้ามแจกให้ผู้ใช้

## หมายเหตุ

- แอปไม่ได้อ่านไฟล์ `.env` แล้ว และ build script ก็ไม่ต้องใช้ `.env.dev` / `.env.prod` อีก การตั้งค่าที่ต่างกันระหว่าง flavor ให้ส่งผ่าน `--dart-define` แทน
- build script ใช้ `fvm flutter` ซึ่งอ่านเวอร์ชัน Flutter จาก `.fvmrc`
- Application ID (Android) คือ `io.github.theeraphats.ncdscreening` (prod), `.dev`, `.local` (เปลี่ยนก่อนแจกจริงครั้งแรก ตามแผนนำร่อง) แอปที่เคยติดตั้งด้วย ID เดิม (`com.fldp.mobileApp*`) จะเป็นคนละแอป ต้องถอนของเดิมออก ส่วน iOS/macOS ยังไม่ได้เปลี่ยน bundle ID เพราะไม่อยู่ในขอบเขตการนำร่อง
