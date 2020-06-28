# Salmon Stats Android

## Configuration

### Running app in development mode

```sh
# Create configuration override for development build
vi .dev_override.env

# Run dev-env-override.sh to combine .env with .dev_override.env
# Note: **DO NOT STORE CREDENTIALS IN `.env` (version-controlled file)**
./scripts/dev-env-override.sh

flutter run
```

## Building for release

Make sure to build with `./scripts/build-release.sh` (to discard changes made by `.dev_override.env`).  
[Read more about "Building for release"](./docs/release.md)

## Generating code

```sh
flutter pub pub run build_runner watch
```

## Generating icons

```sh
flutter pub pub run flutter_launcher_icons:main
```
