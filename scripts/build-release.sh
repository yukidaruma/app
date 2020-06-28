cp .env assets/.env

CHANGED_FILES=$(git status --porcelain | wc -l)
if [ $CHANGED_FILES -gt 0 ]; then
  echo "Error: Please commit or stash uncommited changes before running build script."
  exit
fi

SCRIPT_DIR=$(cd $(dirname $0); pwd)

NO_UPDATE_VERSION=0
RESOLUTION="patch"

while getopts MmV OPT
do
  case $OPT in
     M) RESOLUTION="major";;
     m) RESOLUTION="minor";;
     V) NO_UPDATE_VERSION=1;;
  esac
done

if [ "$NO_UPDATE_VERSION" -eq "0" ]; then
  SCRIPT_DIR=./scripts
  NEW_SEMVER=$(dart $SCRIPT_DIR/incr-version.dart $RESOLUTION) || exit
  TEMP_ARR=(${NEW_SEMVER//\+/ })
  echo "Updated version field in pubspec.yaml to $NEW_SEMVER."
  git add pubspec.yaml
  git commit -m "Release ${TEMP_ARR[0]} (build ${TEMP_ARR[1]})"
  git tag "v${TEMP_ARR[0]}" @
fi

flutter build appbundle --target-platform android-arm,android-arm64,android-x64
