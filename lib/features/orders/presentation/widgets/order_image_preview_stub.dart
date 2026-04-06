import 'package:flutter/material.dart';

Widget buildOrderImagePreview(
  String imagePath, {
  required BoxFit fit,
  required bool isDark,
}) {
  return Image.network(
    imagePath,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Center(
      child: Icon(
        Icons.broken_image,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
    ),
  );
}
