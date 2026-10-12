#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$project_root"
defines_file=${1:?Usage: build_release.sh /path/to/release-defines.json /path/to/ExportOptions.plist}
export_options=${2:?Provide the App Store export-options plist}

# Fail before packaging a production app with broken address suggestions.
python3 - "$defines_file" <<'PY'
import json, sys
with open(sys.argv[1]) as source:
    values = json.load(source)
if values.get('ENV') != 'prod':
    raise SystemExit('Release configuration must specify ENV=prod.')
key = values.get('GOOGLE_MAPS_API_KEY', '')
if not isinstance(key, str) or not key.strip():
    raise SystemExit('Release configuration requires GOOGLE_MAPS_API_KEY.')
PY

flutter build ipa --release -t lib/main_prod.dart \
  --dart-define-from-file="$defines_file" \
  --export-options-plist="$export_options"
