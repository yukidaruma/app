SCRIPT_DIR=$(cd $(dirname "$0"); pwd)
RESOLUTION="patch"
DRY_RUN=0;

while getopts dMmV OPT
do
  case $OPT in
     d) DRY_RUN=1;;
     M) RESOLUTION="major";;
     m) RESOLUTION="minor";;
     V) RESOLUTION="build";;
     *) echo "Invalid option specified. Valid options are: -dMmV"; exit 1;;
  esac
done

OPTS=()
if [ "$DRY_RUN" -eq 1 ]; then
  OPTS+="--dry-run"
fi

# shellcheck disable=SC2086
NEW_SEMVER=$(dart "$SCRIPT_DIR/incr-version.dart" $RESOLUTION $OPTS) || exit
# shellcheck disable=SC2206
TEMP_ARR=(${NEW_SEMVER//\+/ })
NEW_VERSION=${TEMP_ARR[0]}
# NEW_BUILD_NUMBER=${TEMP_ARR[1]}

echo "Updated version field in pubspec.yaml to $NEW_SEMVER."

if [ "$DRY_RUN" -eq 0 ]; then
  git add pubspec.yaml
  git commit -m "chore(internal): Bump version to $NEW_VERSION"
fi

# Generating release notes
LAST_RELEASE=$(git describe --tags $(git rev-list --tags --max-count=1))
NEW_RELEASE_NOTES=$(git --no-pager log --pretty=format:"%B----" "$LAST_RELEASE"..HEAD | dart "$SCRIPT_DIR/gen-release-notes.dart" "$NEW_VERSION")
TMP_FILE=$(mktemp)

if [ "$DRY_RUN" -eq 0 ]; then
  touch CHANGELOG.md # Make sure to create CHANGELOG.md before calling cat
  printf "%s\n\n\n" "$NEW_RELEASE_NOTES" | cat - CHANGELOG.md > "$TMP_FILE"
  rm CHANGELOG.md && mv "$TMP_FILE" CHANGELOG.md
else
  echo "$NEW_RELEASE_NOTES"
fi
