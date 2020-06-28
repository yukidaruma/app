cp .env assets/.env

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
  dart $SCRIPT_DIR/incr-version.dart $RESOLUTION || exit
fi

flutter build appbundle --target-platform android-arm,android-arm64,android-x64
