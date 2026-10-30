import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/core/l10n/generated/app_localizations_en.dart';
import 'package:nemro/core/l10n/generated/app_localizations_vi.dart';

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

  test('generated localizations carry the camera proxy wording', () {
    expect(AppLocalizationsEn().homeLiveSubtitle, 'Camera signal proxy');
    expect(AppLocalizationsVi().homeLiveSubtitle, 'Proxy tín hiệu camera');
    expect(
      AppLocalizationsEn().labDecoderCrossSubject('S002', 'S001'),
      contains('no accuracy claim for S002'),
    );
  });

  test('privacy intro carries the passed version, not a hardcoded one', () {
    // The intro used to hardcode 0.3.0, which would have gone stale on
    // the next version bump; it now takes the version as a parameter.
    expect(AppLocalizationsEn().privacyIntro('9.9.9'), contains('9.9.9'));
    expect(
      AppLocalizationsEn().privacyIntro('9.9.9'),
      isNot(contains('0.3.0')),
    );
  });
}
