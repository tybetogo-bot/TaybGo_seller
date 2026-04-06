import 'dart:io';

import 'package:flutter/material.dart';

Widget buildOrderImagePreview(
  String imagePath, {
  required BoxFit fit,
  required bool isDark,
}) {
  return Image.file(
    File(imagePath),
    fit: fit,
  );
}
