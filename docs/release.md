# Release guide

## Android

### Prepare for release

1. Generate the key using following command:  
   ```
   keytool -genkey -v -keystore <name>.keystore -alias <key alias> -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Add key-related fields to `/android/local.properties`
   ```conf
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=<key alias>
   storeFile=/path/to/<name>.keystore
   ```
3. When running `flutter build apk --release`, if `local.properties` contained `storeFile` key, it will try to sign the build using given key. Otherwise, it will sign the build using debug key.

### Build for release

```sh
# Running `pre-release.sh` will do:
# 1. Increment version field in `pubspec.yaml`.
# 2. Make "Release $newVersion" commit with git tag (it contains release notes as message).
# 3. Update `CHANGELOG.md` from commit messages.
#
# When incrementing major / minor version: Use -M / -m option respectively.
# When incrementing only build number: Use -V option.
# You can also use -d (dry-run) option to see what will happen without
# actually modifying files.
./scripts/pre-release.sh

# If necessary, manually edit `CHANGELOG.md` before running `release.sh` (which depends on `CHANGELOG.md`).
$EDITOR CHANGELOG.md

# In addition to `flutter build`, `release.sh` does following things:
# 1. Reset `assets/.env` to default.
# 2. Stop if you have changes to files other than `CHANGELOG.md`.
# 3. Generate `assets/release_notes.html` from `CHANGELOG.md`.
# 4. Make commit with release notes tag (Update to `CHANGELOG.md` should be attached to this commit).
./scripts/release.sh
```
