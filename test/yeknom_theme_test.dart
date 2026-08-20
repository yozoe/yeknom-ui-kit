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

    test('provides distinct light and dark color presets', () {
      final lightActiveColors = <Color>{};
      final darkActiveColors = <Color>{};

      for (final preset in YeknomColorPreset.values) {
        final light = YeknomPalette.fromPreset(preset, Brightness.light);
        final dark = YeknomPalette.fromPreset(preset, Brightness.dark);

        expect(light.dark, isFalse, reason: preset.name);
        expect(dark.dark, isTrue, reason: preset.name);
        expect(light.module, isNot(light.bench), reason: preset.name);
        expect(dark.module, isNot(dark.bench), reason: preset.name);
        lightActiveColors.add(light.active);
        darkActiveColors.add(dark.active);
      }

      expect(lightActiveColors, hasLength(YeknomColorPreset.values.length));
      expect(darkActiveColors, hasLength(YeknomColorPreset.values.length));
    });

    test('keeps the original workbench palette as the default', () {
      for (final brightness in Brightness.values) {
        final defaultPalette = YeknomPalette.fromBrightness(brightness);
        final workbenchPalette = YeknomPalette.fromPreset(
          YeknomColorPreset.workbench,
          brightness,
        );

        expect(
          [
            defaultPalette.bench,
            defaultPalette.module,
            defaultPalette.trace,
            defaultPalette.signal,
            defaultPalette.active,
            defaultPalette.ack,
            defaultPalette.fault,
            defaultPalette.warning,
            defaultPalette.onSignal,
          ],
          [
            workbenchPalette.bench,
            workbenchPalette.module,
            workbenchPalette.trace,
            workbenchPalette.signal,
            workbenchPalette.active,
            workbenchPalette.ack,
            workbenchPalette.fault,
            workbenchPalette.warning,
            workbenchPalette.onSignal,
          ],
        );
      }
    });

    test('near-black presets keep their dark surfaces close to black', () {
      for (final preset in [
        YeknomColorPreset.obsidian,
        YeknomColorPreset.midnight,
        YeknomColorPreset.blackberry,
      ]) {
        final palette = YeknomPalette.fromPreset(preset, Brightness.dark);

        expect(
          palette.bench.computeLuminance(),
          lessThan(0.005),
          reason: '${preset.name} bench',
        );
        expect(
          palette.module.computeLuminance(),
          lessThan(0.012),
          reason: '${preset.name} module',
        );
        expect(
          _contrast(palette.module, palette.trace),
          greaterThanOrEqualTo(7),
          reason: '${preset.name} primary text',
        );
      }
    });

    test('obsidian uses a neutral graphite active color', () {
      final light = YeknomPalette.fromPreset(
        YeknomColorPreset.obsidian,
        Brightness.light,
      );
      final dark = YeknomPalette.fromPreset(
        YeknomColorPreset.obsidian,
        Brightness.dark,
      );

      expect(light.active, const Color(0xFF1B2228));
      expect(dark.active, const Color(0xFF99A2A8));
      expect(_contrast(light.active, light.module), greaterThanOrEqualTo(4.5));
      expect(_contrast(dark.active, dark.module), greaterThanOrEqualTo(4.5));

      final neutralStatus = Color.alphaBlend(
        YeknomTone.neutral.resolve(dark),
        dark.module,
      );
      expect(
        _contrast(neutralStatus, dark.module),
        greaterThanOrEqualTo(3),
        reason: 'dark neutral status indicators remain visible',
      );
      expect(
        _contrast(dark.active, neutralStatus),
        greaterThanOrEqualTo(1.75),
        reason: 'dark info and neutral status indicators remain distinct',
      );
    });

    test('sage preset avoids pure white and pure black surfaces', () {
      final light = YeknomPalette.fromPreset(
        YeknomColorPreset.sage,
        Brightness.light,
      );
      final dark = YeknomPalette.fromPreset(
        YeknomColorPreset.sage,
        Brightness.dark,
      );

      expect(light.bench, isNot(Colors.white));
      expect(light.module, isNot(Colors.white));
      expect(dark.bench, isNot(Colors.black));
      expect(dark.module, isNot(Colors.black));
      expect(_contrast(light.module, light.trace), greaterThanOrEqualTo(7));
      expect(_contrast(dark.module, dark.trace), greaterThanOrEqualTo(7));
    });

    test('muted text meets contrast after compositing on surfaces', () {
      for (final preset in YeknomColorPreset.values) {
        for (final brightness in Brightness.values) {
          final palette = YeknomPalette.fromPreset(preset, brightness);

          for (final surface in [palette.bench, palette.module]) {
            final composited = Color.alphaBlend(palette.muted, surface);
            expect(
              _contrast(composited, surface),
              greaterThanOrEqualTo(4.5),
              reason: '${preset.name} ${brightness.name}',
            );
          }
        }
      }
    });

    test('neutral status indicators meet graphical contrast on surfaces', () {
      for (final preset in YeknomColorPreset.values) {
        for (final brightness in Brightness.values) {
          final palette = YeknomPalette.fromPreset(preset, brightness);
          final neutral = YeknomTone.neutral.resolve(palette);

          for (final surface in [palette.bench, palette.module]) {
            final badgeBackground = Color.alphaBlend(
              neutral.withValues(alpha: 0.09),
              surface,
            );
            expect(
              _contrast(neutral, badgeBackground),
              greaterThanOrEqualTo(3),
              reason: '${preset.name} ${brightness.name}',
            );
          }
        }
      }
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

  test('theme applies a preset and gives an explicit palette precedence', () {
    final presetTheme = YeknomTheme.light(preset: YeknomColorPreset.orchid);
    final custom = YeknomPalette.fromBrightness(
      Brightness.light,
    ).copyWith(active: Colors.yellow);
    final customTheme = YeknomTheme.light(
      preset: YeknomColorPreset.orchid,
      palette: custom,
    );

    expect(
      presetTheme.extension<YeknomPalette>()?.active,
      YeknomPalette.fromPreset(
        YeknomColorPreset.orchid,
        Brightness.light,
      ).active,
    );
    expect(customTheme.extension<YeknomPalette>(), same(custom));
  });

  test('solid color-scheme text roles meet normal-text contrast', () {
    for (final preset in YeknomColorPreset.values) {
      for (final theme in [
        YeknomTheme.light(preset: preset),
        YeknomTheme.dark(preset: preset),
      ]) {
        final scheme = theme.colorScheme;

        expect(
          _contrast(scheme.surface, scheme.onSurface),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.name} surface',
        );
        expect(
          _contrast(scheme.primary, scheme.onPrimary),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.name} primary',
        );
        expect(
          _contrast(scheme.secondary, scheme.onSecondary),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.name} secondary',
        );
        expect(
          _contrast(scheme.error, scheme.onError),
          greaterThanOrEqualTo(4.5),
          reason: '${preset.name} error',
        );
      }
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
