#!/bin/sh
set -eu
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$project_root"
defines_file=${1:?Usage: build_aab.sh /path/to/release-defines.json}
python3 scripts/release/preflight.py "$defines_file"
test -f android/key.properties || { echo 'A release signing keystore is required.' >&2; exit 1; }
# Earlier per-ABI APK releases used codes up to 4000 + the Flutter build.
# Keep the universal Play bundle above those codes while iOS uses its pubspec build number.
android_build=$(python3 - <<'PY'
import re
from pathlib import Path
build = int(re.search(r'^version:.*\+(\d+)', Path('pubspec.yaml').read_text(), re.M).group(1))
print(4000 + build)
PY
)
flutter build appbundle --release --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file="$defines_file" --build-number="$android_build"
