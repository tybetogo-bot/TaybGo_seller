/// IO (non-web) stub for [pickFileFromWeb]. Never called on mobile/desktop.
library;

import 'dart:typed_data';

/// Result of a web file pick.
class WebPickedFile {
  const WebPickedFile({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
}

/// Opens a browser file picker and returns the picked file.
///
/// This stub is only used on non-web platforms to keep the conditional
/// import tree compiling. It is never invoked at runtime because callers
/// guard with `kIsWeb`.
Future<WebPickedFile?> pickFileFromWeb({String accept = ''}) {
  throw UnsupportedError('pickFileFromWeb is only available on web');
}
