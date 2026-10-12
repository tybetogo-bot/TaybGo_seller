#!/usr/bin/env python3
"""Inspect a seller App Store export without modifying its signed payload."""
import argparse, hashlib, json, plistlib, re, subprocess, tempfile, zipfile
from pathlib import Path

def command(*args):
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(' '.join(args) + '\n' + result.stderr)
    return result.stdout

parser = argparse.ArgumentParser()
parser.add_argument('ipa', type=Path)
parser.add_argument('--report', type=Path, required=True)
parser.add_argument('--version', default='1.0.22')
parser.add_argument('--build', default='27')
args = parser.parse_args()
ipa = args.ipa.resolve()
with zipfile.ZipFile(ipa) as archive:
    assert archive.testzip() is None, 'IPA ZIP integrity failure'
with tempfile.TemporaryDirectory(prefix='seller-ipa-', dir='/private/tmp') as folder:
    command('ditto', '-x', '-k', str(ipa), folder)
    apps = list(Path(folder).glob('Payload/*.app'))
    assert len(apps) == 1, 'Expected one app bundle'
    app = apps[0]
    metadata = plistlib.loads((app/'Info.plist').read_bytes())
    assert metadata['CFBundleIdentifier'] == 'com.taybgo.seller'
    assert metadata['CFBundleShortVersionString'] == args.version
    assert metadata['CFBundleVersion'] == args.build
    command('codesign', '--verify', '--deep', '--strict', '--verbose=2', str(app))
    identity = subprocess.run(['codesign', '-dv', '--verbose=4', str(app)], capture_output=True, text=True)
    assert identity.returncode == 0 and 'Authority=Apple Distribution:' in identity.stderr
    assert metadata['MinimumOSVersion'] == '15.5'
    assert metadata.get('CFBundleIcons'), 'Missing app icon metadata'
    entitlement = plistlib.loads(command('codesign', '-d', '--entitlements', ':-', str(app)).encode())
    assert entitlement['com.apple.developer.team-identifier'] == 'Z8ZLXJ9696'
    assert entitlement['application-identifier'] == 'Z8ZLXJ9696.com.taybgo.seller'
    assert entitlement['aps-environment'] == 'production'
    assert entitlement.get('get-task-allow') is False
    profile = plistlib.loads(command('security', 'cms', '-D', '-i', str(app/'embedded.mobileprovision')).encode())
    assert 'ProvisionedDevices' not in profile and not profile.get('ProvisionsAllDevices', False)
    assert profile['Entitlements']['aps-environment'] == 'production'
    firebase = plistlib.loads((app/'GoogleService-Info.plist').read_bytes())
    assert firebase['BUNDLE_ID'] == 'com.taybgo.seller'
    assert firebase['PROJECT_ID'] == 'sellertaybgo'
    assert firebase['GOOGLE_APP_ID'] == '1:188938523542:ios:1e5c62e1094e84646343b7'
    scene = metadata['UIApplicationSceneManifest']['UISceneConfigurations']['UIWindowSceneSessionRoleApplication'][0]
    assert scene['UISceneDelegateClassName'] == 'FlutterSceneDelegate'
    for key in ['NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription', 'NSLocationWhenInUseUsageDescription']:
        assert metadata.get(key), key
    assert (app/'Base.lproj/Main.storyboardc').exists()
    assert (app/'Base.lproj/LaunchScreen.storyboardc').exists()
    font_root = app/'Frameworks/App.framework/flutter_assets/assets/fonts'
    font_manifest = json.loads(Path('assets/fonts/manifest.json').read_text())
    for font in font_manifest:
        data = (font_root/font['file']).read_bytes()
        assert hashlib.sha256(data).hexdigest() == font['sha256'], font['file']
    for name in ['Poppins-OFL.txt', 'Cairo-OFL.txt']:
        assert (font_root/name).exists(), name
    sound_reports = []
    for sound in ['notif_sound.caf', 'notif_sound_1.caf', 'notif_sound_3.caf', 'notif_sound_5.caf', 'notif_sound_7.caf']:
        assert (app/sound).exists(), sound
        audio_info = command('afinfo', str(app/sound))
        duration = float(re.search(r'estimated duration:\s+([\d.]+)', audio_info).group(1))
        assert 0 < duration < 30, (sound, duration)
        assert abs(duration - (29 if sound == 'notif_sound.caf' else 1.066667 * int(sound[-5]))) < 0.05, (sound, duration)
        assert hashlib.sha256((app/sound).read_bytes()).hexdigest() == hashlib.sha256((Path('ios/Runner')/sound).read_bytes()).hexdigest(), sound
        sound_reports.append({'file': sound, 'seconds': duration})
    privacy = []
    for path in app.rglob('PrivacyInfo.xcprivacy'):
        privacy.append({'path':str(path.relative_to(app)), 'declarations':plistlib.loads(path.read_bytes())})
    binaries = []
    for binary in [app/metadata['CFBundleExecutable']] + [p/p.stem for p in (app/'Frameworks').glob('*.framework')]:
        if not binary.exists():
            continue
        architectures = command('lipo', '-archs', str(binary)).strip()
        assert architectures == 'arm64', (binary, architectures)
        binaries.append({'path':str(binary.relative_to(app)), 'architectures':architectures, 'uuid':command('dwarfdump','--uuid',str(binary)).strip(), 'dependencies':command('otool','-L',str(binary)).splitlines()[1:]})
    report = {'ipa':str(ipa),'sha256':hashlib.sha256(ipa.read_bytes()).hexdigest(),'bytes':ipa.stat().st_size,'metadata':metadata,'entitlements':entitlement,'profile':{'name':profile['Name'],'uuid':profile['UUID'],'expires':str(profile['ExpirationDate'])},'firebase':{'project':firebase['PROJECT_ID'],'appId':firebase['GOOGLE_APP_ID'],'bundleId':firebase['BUNDLE_ID']},'verifiedFontCount':len(font_manifest),'privacyManifests':privacy,'binaries':binaries,'signatureVerification':'passed','limitations':['Privacy declaration accuracy requires an app/SDK usage review.','Physical-device launch and push delivery remain untested.','App Store Connect build-number availability and processing are unverified.']}
    report['notificationSounds'] = sound_reports
    args.report.write_text(json.dumps(report,indent=2,default=str)+'\n')
print('App Store IPA identity, signatures, production APNs, resources and architectures verified.')
