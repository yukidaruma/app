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
# Running the `build-release.sh` will
# 1. Increment version field in `pubspec.yaml`.
# 2. Runs `flutter build`.
./scripts/build-release.sh

# When you do not want to update version field: Use `-V` option.
./scripts/build-release.sh -V

# When incrementing major / minor version: Use -M / -m option respectively.
```
