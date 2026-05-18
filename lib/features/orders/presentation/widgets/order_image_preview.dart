import 'package:flutter/material.dart';

import 'order_image_preview_stub.dart'
    if (dart.library.io) 'order_image_preview_io.dart' as platform;

Widget buildOrderImagePreview(
  String imagePath, {
  required BoxFit fit,
  required bool isDark,
}) {
  return platform.buildOrderImagePreview(
    imagePath,
    fit: fit,
    isDark: isDark,
  );
}
