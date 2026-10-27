import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Vietnamese ARB files have the same keys', () {
    final english = jsonDecode(
      File('lib/core/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    final vietnamese = jsonDecode(
      File('lib/core/l10n/app_vi.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

    final englishKeys = english.keys
        .where((key) => !key.startsWith('@'))
        .toSet();
    final vietnameseKeys = vietnamese.keys
        .where((key) => !key.startsWith('@'))
        .toSet();

    expect(vietnameseKeys, englishKeys);
    expect(englishKeys, isNotEmpty);
  });
}
