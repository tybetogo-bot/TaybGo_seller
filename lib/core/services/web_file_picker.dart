/// Conditional dispatcher for the web file picker.
///
/// On web, this re-exports the real implementation backed by a native
/// `<input type="file">` element (via `package:web`).
/// On non-web platforms, this re-exports the stub, which is never called
/// at runtime (callers guard with `kIsWeb`) but keeps the tree compiling.
library;

export 'web_file_picker_stub.dart'
    if (dart.library.js_interop) 'web_file_picker_web.dart';
