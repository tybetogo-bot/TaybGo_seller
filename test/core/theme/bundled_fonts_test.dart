import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all bundled UI font weights load with networking disabled', () async {
    final previous = GoogleFonts.config.allowRuntimeFetching;
    GoogleFonts.config.allowRuntimeFetching = false;
    addTearDown(() => GoogleFonts.config.allowRuntimeFetching = previous);

    for (final weight in FontWeight.values) {
      GoogleFonts.poppins(fontWeight: weight);
      if (weight != FontWeight.w100) {
        GoogleFonts.cairo(fontWeight: weight);
      }
    }
    await GoogleFonts.pendingFonts();
  });
}
