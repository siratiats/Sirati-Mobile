import 'package:flutter_test/flutter_test.dart';
import 'package:sirati/theme/app_contrast.dart';
import 'package:sirati/theme/sirati_colors.dart';

void main() {
  for (final entry in {
    'light': SiratiColors.light,
    'dark': SiratiColors.dark,
  }.entries) {
    group('${entry.key} semantic tokens', () {
      final c = entry.value;

      test('aliases map to role colors', () {
        expect(c.onSurface, c.textPrimary);
        expect(c.onSurfaceVariant, c.textSecondary);
        expect(c.onSurfaceMuted, c.textHint);
        expect(c.outline, c.border);
        expect(c.outlineVariant, c.borderStrong);
      });

      test('WCAG AA contrast pairs', () {
        final failures = <String>[];
        for (final pair in AppContrast.pairs(c)) {
          if (!pair.passes) {
            failures.add(
              '${pair.name}: ${pair.ratio.toStringAsFixed(2)} < ${pair.minRatio}',
            );
          }
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      });
    });
  }
}
