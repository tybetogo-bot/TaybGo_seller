#!/usr/bin/env python3
"""Check production release inputs without printing credentials."""
import argparse
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('defines', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
values = json.loads(args.defines.read_text())
if values.get('ENV') != 'prod':
    raise SystemExit('Release configuration must specify ENV=prod.')
key = values.get('GOOGLE_MAPS_API_KEY')
if not isinstance(key, str) or not key.strip():
    raise SystemExit('Release configuration requires GOOGLE_MAPS_API_KEY.')
if values.get('API_BASE_URL', 'https://taybgo.com') != 'https://taybgo.com':
    raise SystemExit('Release configuration must use the production API.')
version = re.search(r'^version:\s*(\S+)', (root/'pubspec.yaml').read_text(), re.M).group(1)
config = (root/'lib/core/config/app_config.dart').read_text()
if f"appVersion = '{version}'" not in config:
    raise SystemExit('pubspec and AppConfig versions must match.')
release_key = 'v' + version.split('+')[0].replace('.', '')
for path in (root/'assets/translations').glob('*.json'):
    notes = json.loads(path.read_text())['changelog'][release_key]
    if not all(notes.get(k) for k in ('date', 'change1', 'change2', 'change3')):
        raise SystemExit(f'Missing release notes: {path.name}')
print(f'Production release {version}: Places key, API and localized notes verified.')
