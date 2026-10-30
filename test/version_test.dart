import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/core/constants/app_constants.dart';

void main() {
  test('AppConstants.version matches the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+\d+',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'pubspec.yaml needs a version line');
    expect(AppConstants.version, match!.group(1));
  });
}
