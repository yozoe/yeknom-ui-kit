import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

void main() {
  group('YeknomPalette', () {
    test('provides the light semantic colors', () {
      final palette = YeknomPalette.fromBrightness(Brightness.light);

      expect(palette.bench, const Color(0xFFF3F7F6));
      expect(palette.module, const Color(0xFFFFFFFF));
      expect(palette.trace, const Color(0xFF172326));
      expect(palette.signal, const Color(0xFF955811));
      expect(palette.active, const Color(0xFF2D7787));
      expect(palette.ack, const Color(0xFF287B54));
      expect(palette.fault, const Color(0xFFB94F43));
    });

    test('provides the dark semantic colors', () {
      final palette = YeknomPalette.fromBrightness(Brightness.dark);

      expect(palette.bench, const Color(0xFF12191C));
      expect(palette.module, const Color(0xFF1B2529));
      expect(palette.trace, const Color(0xFFDCE6E3));
      expect(palette.signal, const Color(0xFFE6B36A));
      expect(palette.active, const Color(0xFF78B9C7));
      expect(palette.ack, const Color(0xFF8CC7A4));
      expect(palette.fault, const Color(0xFFEF8F7E));
    });

    test('supports custom values and interpolation', () {
      final light = YeknomPalette.fromBrightness(Brightness.light);
      final dark = YeknomPalette.fromBrightness(Brightness.dark);
      final custom = light.copyWith(active: Colors.purple);
      final midpoint = light.lerp(dark, 0.5);

      expect(custom.active, Colors.purple);
      expect(custom.signal, light.signal);
      expect(midpoint.active, Color.lerp(light.active, dark.active, 0.5));
      expect(midpoint.dark, isTrue);
    });
  });

  testWidgets('theme attaches its palette and maps component colors', (
    tester,
  ) async {
    late ThemeData theme;
    late YeknomPalette palette;

    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.light(),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            palette = YeknomPalette.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(theme.scaffoldBackgroundColor, palette.bench);
    expect(theme.colorScheme.primary, palette.active);
    expect(theme.colorScheme.secondary, palette.signal);
    expect(theme.colorScheme.error, palette.fault);
    expect(theme.inputDecorationTheme.fillColor, palette.field);
    expect(
      theme.switchTheme.trackColor?.resolve({WidgetState.selected}),
      palette.active,
    );
    expect(theme.dialogTheme.backgroundColor, palette.module);
    expect(theme.extension<YeknomPalette>(), same(palette));
  });

  test('theme accepts a custom palette', () {
    final custom = YeknomPalette.fromBrightness(
      Brightness.light,
    ).copyWith(active: Colors.yellow);
    final theme = YeknomTheme.light(palette: custom);

    expect(theme.colorScheme.primary, Colors.yellow);
    expect(theme.colorScheme.onPrimary, const Color(0xFF102226));
    expect(
      _contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(theme.extension<YeknomPalette>(), same(custom));
  });

  test('solid color-scheme text roles meet normal-text contrast', () {
    for (final theme in [YeknomTheme.light(), YeknomTheme.dark()]) {
      final scheme = theme.colorScheme;

      expect(
        _contrast(scheme.surface, scheme.onSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.error, scheme.onError),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

double _contrast(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
