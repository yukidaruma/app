# Release guide

## Android

### Prepare for release

1. Generate the key using following command:  
   ```
   keytool -genkey -v -keystore <name>.keystore -alias <key alias> -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Add key-related fields to `/android/local.properties`
   ```
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=<key alias>
   storeFile=/path/to/<name>.keystore
   ```
3. When running `flutter build apk --release`, if `local.properties` contained `storeFile` key, it will try to sign the build using given key. Otherwise, it will sign the build using debug key.

### Build for release

```
flutter build appbundle --target-platform android-arm,android-arm64,android-x64
```
