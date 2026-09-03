import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sirati/theme/app_theme.dart';

void main() {
  test('spacing scale is the only allowed layout steps', () {
    expect(AppSpacing.scale, [4, 8, 12, 16, 20, 24, 32]);
  });

  test('radius and elevation tokens exist per surface type', () {
    expect(AppRadius.sm, 10);
    expect(AppRadius.md, 14);
    expect(AppRadius.lg, 16);
    expect(AppRadius.xl, 18);
    expect(AppElevation.none, 0);
    expect(AppElevation.card, 1);
    expect(AppElevation.raised, 3);
    expect(AppElevation.sheet, 6);
    expect(AppElevation.dialog, 12);
  });

  test('component library does not use magic EdgeInsets numbers', () {
    final dir = Directory('lib/widgets/components');
    expect(dir.existsSync(), isTrue);

    final allowed = {
      ...AppSpacing.scale.map((v) => v.toInt()),
      AppTouchTarget.min.toInt(),
    };
    final magic = RegExp(r'EdgeInsets\.(all|symmetric)\(([^\)]*)\)');
    final numbers = RegExp(r'(\d+(?:\.\d+)?)');
    final offenders = <String>[];

    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in magic.allMatches(source)) {
        for (final n in numbers.allMatches(match.group(2)!)) {
          final value = double.parse(n.group(1)!);
          if (!allowed.contains(value.round())) {
            offenders.add('${file.uri.pathSegments.last}: ${match.group(0)}');
          }
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('component library does not use raw Color( literals', () {
    final dir = Directory('lib/widgets/components');
    final raw = RegExp(r'Color\s*\(\s*0x');
    final offenders = <String>[];
    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      if (raw.hasMatch(source)) {
        offenders.add(file.uri.pathSegments.last);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join(', '));
  });
}
