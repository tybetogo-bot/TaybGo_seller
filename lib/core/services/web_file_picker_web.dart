/// Web implementation of [pickFileFromWeb] using a native
/// `<input type="file">` element.
///
/// This bypasses the `file_picker` package on web, which has a known
/// issue on recent browsers/Flutter where the underlying input element
/// is removed from the DOM immediately after being clicked — leading to
/// dropped `change` events and an error surfacing as "failed to pick file".
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Result of a web file pick.
class WebPickedFile {
  const WebPickedFile({required this.bytes, required this.name});
  final Uint8List bytes;
  final String name;
}

/// Opens a browser file picker and returns the picked file as bytes.
///
/// Returns `null` if the user cancelled or the file could not be read.
/// [accept] is passed through as the HTML `accept` attribute (e.g. `image/*`
/// or `.pdf,.doc`). Leave empty for any file type.
Future<WebPickedFile?> pickFileFromWeb({String accept = ''}) {
  final completer = Completer<WebPickedFile?>();

  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept
    ..multiple = false
    ..style.display = 'none';

  void complete(WebPickedFile? result) {
    if (completer.isCompleted) return;
    completer.complete(result);
    // Defer removal so the change event listener can finish running in
    // some browsers. Removing synchronously here is safe but defensive.
    try {
      input.remove();
    } catch (_) {
      // ignore
    }
  }

  // Set up change listener BEFORE inserting / clicking so nothing is lost.
  input.onChange.listen((web.Event event) {
    final files = input.files;
    if (files == null || files.length == 0) {
      complete(null);
      return;
    }
    final file = files.item(0);
    if (file == null) {
      complete(null);
      return;
    }

    final reader = web.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result == null) {
        complete(null);
        return;
      }
      if (result.isA<JSArrayBuffer>()) {
        final bytes = (result as JSArrayBuffer).toDart.asUint8List();
        complete(WebPickedFile(bytes: bytes, name: file.name));
      } else {
        complete(null);
      }
    });
    reader.addEventListener(
      'error',
      ((web.Event _) => complete(null)).toJS,
    );
    reader.readAsArrayBuffer(file);
  });

  // Fallback: if the user cancels the OS dialog there's no reliable
  // cross-browser event. Watch for focus returning to the window; if no
  // file was picked within a short window after focus return, treat as
  // cancelled so the caller's UI can reset.
  JSFunction? focusListener;
  focusListener = ((web.Event _) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!completer.isCompleted) {
        if (focusListener != null) {
          web.window.removeEventListener('focus', focusListener);
        }
        complete(null);
      }
    });
  }).toJS;
  web.window.addEventListener('focus', focusListener);

  // Keep the input attached to the DOM while the picker is open — this
  // is the key difference from file_picker's web implementation, which
  // detaches it right after click().
  web.document.body?.append(input);
  input.click();

  return completer.future;
}
