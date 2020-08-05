# Only changes to CHANGELOG.md is allowed
CHANGED_FILES=$(git status --porcelain -- ':!CHANGELOG.md' ':!pubspec.yaml' | wc -l)
if [ "$CHANGED_FILES" -gt 0 ]; then
  echo "Error: Please commit or stash uncommited changes before running release script."
  echo "Note: Changes to \`CHANGELOG.md\` / \`pubspec.yaml\` are allowed."
  exit
fi

SCRIPT_DIR=$(cd $(dirname "$0"); pwd)

RELEASE_NOTES=$(git diff -U0 -- CHANGELOG.md | grep '^\+' | grep -Ev '^\+{2,} b/' | sed -e 's/^\+//')
NEW_VERSION=$(head -1 CHANGELOG.md | sed -e 's/^# Version \(.\+\) .\+$/\1/')

< CHANGELOG.md dart "$SCRIPT_DIR/convert-markdown.dart" > assets/release_notes.html
git add CHANGELOG.md assets/release_notes.html pubspec.yaml
git commit -m "Release $NEW_VERSION"
git -c core.commentChar=";" tag -a "v$NEW_VERSION" -m "'$RELEASE_NOTES'"
