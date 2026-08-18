import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart';

void main() {
  test('App tokens expose stable dimensions and interpolate all roles', () {
    final light = YeknomAppThemeTokens.fromColorScheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF5847D8),
        brightness: Brightness.light,
      ),
    );
    final dark = YeknomAppThemeTokens.fromColorScheme(
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFB9AEFF),
        brightness: Brightness.dark,
      ),
    );
    final changed = light.copyWith(
      contentMaxWidth: 960,
      cardRadius: 30,
      canvas: Colors.amber,
      interactiveAccent: Colors.cyan,
      heroAccent: Colors.pink,
    );
    final midpoint = light.lerp(dark, 0.5);

    expect(light.contentMaxWidth, 1120);
    expect(light.cardRadius, 18);
    expect(light.heroRadius, 24);
    expect(light.controlRadius, 14);
    expect(light.modalRadius, 22);
    expect(light.minimumTapTarget, 48);
    expect(light.primaryButtonHeight, 56);
    expect(light.pageGutter, 20);
    expect(changed.contentMaxWidth, 960);
    expect(changed.cardRadius, 30);
    expect(changed.canvas, Colors.amber);
    expect(changed.interactiveAccent, Colors.cyan);
    expect(changed.heroAccent, Colors.pink);
    expect(changed.surface, light.surface);
    expect(midpoint.canvas, Color.lerp(light.canvas, dark.canvas, 0.5));
    expect(
      midpoint.heroBackground,
      Color.lerp(light.heroBackground, dark.heroBackground, 0.5),
    );
    expect(
      midpoint.interactiveAccent,
      Color.lerp(light.interactiveAccent, dark.interactiveAccent, 0.5),
    );
    expect(
      midpoint.heroAction,
      Color.lerp(light.heroAction, dark.heroAction, 0.5),
    );
    expect(light.heroBackground, isNot(light.heroAccent));
    expect(
      ThemeData.estimateBrightnessForColor(light.heroBackground),
      Brightness.dark,
    );
    expect(
      _contrast(light.heroBackground, light.heroForeground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(light.heroBackground, light.heroMuted),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(light.heroAction, light.heroForeground),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('App themes always attach palette and App tokens for every preset', () {
    for (final preset in YeknomColorPreset.values) {
      for (final brightness in Brightness.values) {
        final theme = YeknomAppTheme.build(brightness, preset: preset);
        final palette = theme.extension<YeknomPalette>();
        final tokens = theme.extension<YeknomAppThemeTokens>();
        final reason = '${preset.name} ${brightness.name}';

        expect(palette, isNotNull, reason: '${preset.name} palette');
        expect(tokens, isNotNull, reason: '${preset.name} tokens');
        expect(palette?.dark, brightness == Brightness.dark);
        expect(theme.colorScheme.primary, palette?.active);
        expect(theme.colorScheme.secondary, palette?.signal);
        expect(theme.scaffoldBackgroundColor, tokens?.canvas);
        expect(theme.cardTheme.color, tokens?.surface);
        expect(tokens?.canvas, palette?.bench);
        expect(tokens?.surface, palette?.module);
        expect(tokens?.heroBackground, isNot(palette?.active));
        expect(tokens?.heroAccent, isNot(tokens?.heroBackground));
        expect(
          ThemeData.estimateBrightnessForColor(tokens!.heroBackground),
          Brightness.dark,
          reason: '$reason neutral hero',
        );
        _expectThemeContrast(theme, tokens, reason);
        expect(
          _contrast(tokens.interactiveAccent, tokens.surface),
          greaterThanOrEqualTo(3),
          reason: '$reason card focus indicator',
        );
        expect(
          _contrast(tokens.interactiveAccent, tokens.surfaceSoft),
          greaterThanOrEqualTo(3),
          reason: '$reason tile focus indicator',
        );
        expect(
          theme.progressIndicatorTheme.color,
          tokens.interactiveAccent,
          reason: '$reason progress accent',
        );
      }
    }
  });

  test('on-primary chooses the candidate with the stronger contrast', () {
    const neutralActive = Color(0xFF999999);
    const darkCandidate = Color(0xFF111719);
    final custom = YeknomPalette.fromBrightness(
      Brightness.light,
    ).copyWith(active: neutralActive);
    final theme = YeknomAppTheme.light(palette: custom);

    expect(theme.colorScheme.onPrimary, darkCandidate);
    expect(
      _contrast(neutralActive, theme.colorScheme.onPrimary),
      greaterThan(_contrast(neutralActive, Colors.white)),
    );
    expect(
      _contrast(neutralActive, theme.colorScheme.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('on-primary falls back to black when brand candidates both fail', () {
    const neutralActive = Color(0xFF7A7A7A);
    final custom = YeknomPalette.fromBrightness(
      Brightness.light,
    ).copyWith(active: neutralActive);
    final theme = YeknomAppTheme.light(palette: custom);

    expect(theme.colorScheme.onPrimary, Colors.black);
    expect(
      _contrast(neutralActive, theme.colorScheme.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('custom mid-tone palettes keep every content role readable', () {
    for (final brightness in Brightness.values) {
      final weakTrace = brightness == Brightness.light
          ? const Color(0xFFF8F8F8)
          : const Color(0xFF202020);
      final custom = YeknomPalette.fromBrightness(brightness).copyWith(
        active: const Color(0xFF999999),
        signal: const Color(0xFF969696),
        trace: weakTrace,
        muted: weakTrace.withValues(alpha: 0.68),
        fault: const Color(0xFF999999),
      );
      final theme = YeknomAppTheme.build(brightness, palette: custom);
      final tokens = theme.extension<YeknomAppThemeTokens>()!;

      expect(theme.colorScheme.primary, custom.active);
      expect(tokens.heroBackground, isNot(custom.active));
      expect(
        ThemeData.estimateBrightnessForColor(tokens.heroBackground),
        Brightness.dark,
      );
      expect(theme.colorScheme.onSurface, isNot(custom.trace));
      expect(
        _contrast(tokens.interactiveAccent, tokens.surface),
        greaterThanOrEqualTo(3),
      );
      expect(
        _contrast(tokens.interactiveAccent, tokens.surfaceSoft),
        greaterThanOrEqualTo(3),
      );
      _expectThemeContrast(theme, tokens, 'custom ${brightness.name}');
    }
  });

  test('explicit palette takes precedence over preset', () {
    final custom = YeknomPalette.fromBrightness(
      Brightness.light,
    ).copyWith(active: const Color(0xFF5736A8));
    final theme = YeknomAppTheme.light(
      palette: custom,
      preset: YeknomColorPreset.sage,
    );
    final tokens = theme.extension<YeknomAppThemeTokens>()!;

    expect(theme.extension<YeknomPalette>(), same(custom));
    expect(theme.colorScheme.primary, custom.active);
    expect(tokens.heroBackground, isNot(custom.active));
    expect(
      ThemeData.estimateBrightnessForColor(tokens.heroBackground),
      Brightness.dark,
    );
    expect(tokens.canvas, theme.scaffoldBackgroundColor);
  });

  test('App theme uses restrained radii and neutral layered surfaces', () {
    final theme = YeknomAppTheme.light();
    final tokens = theme.extension<YeknomAppThemeTokens>()!;
    final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;
    final enabledField =
        theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
    final focusedField =
        theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
    final dialogShape = theme.dialogTheme.shape! as RoundedRectangleBorder;
    final sheetShape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
    final filledStyle = theme.filledButtonTheme.style!;
    final outlinedStyle = theme.outlinedButtonTheme.style!;
    final iconStyle = theme.iconButtonTheme.style!;

    expect(cardShape.borderRadius, BorderRadius.circular(tokens.cardRadius));
    expect(cardShape.side.style, BorderStyle.solid);
    expect(enabledField.borderRadius, BorderRadius.circular(14));
    expect(enabledField.borderSide.style, BorderStyle.solid);
    expect(
      _contrast(tokens.surface, enabledField.borderSide.color),
      greaterThanOrEqualTo(3),
    );
    expect(focusedField.borderSide.width, 1.8);
    expect(filledStyle.minimumSize?.resolve(const {}), const Size(48, 56));
    expect(outlinedStyle.minimumSize?.resolve(const {}), const Size(48, 56));
    expect(outlinedStyle.side?.resolve(const {})?.style, BorderStyle.solid);
    expect(
      _contrast(
        tokens.surface,
        outlinedStyle.side!.resolve(const <WidgetState>{})!.color,
      ),
      greaterThanOrEqualTo(3),
    );
    expect(iconStyle.minimumSize?.resolve(const {}), const Size.square(48));
    expect(theme.navigationBarTheme.height, 72);
    expect(theme.navigationBarTheme.elevation, 0);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.dialogTheme.elevation, 8);
    expect(theme.popupMenuTheme.elevation, 6);
    expect(dialogShape.borderRadius, BorderRadius.circular(tokens.modalRadius));
    expect(dialogShape.side.style, BorderStyle.solid);
    expect(
      sheetShape.borderRadius,
      BorderRadius.vertical(top: Radius.circular(tokens.modalRadius)),
    );
    expect(tokens.canvas, theme.extension<YeknomPalette>()!.bench);
    expect(tokens.surface, theme.extension<YeknomPalette>()!.module);
    expect(tokens.shadowColor.a, lessThanOrEqualTo(0.08));
    expect(theme.textTheme.displaySmall?.fontSize, 40);
    expect(theme.textTheme.bodyLarge?.fontSize, 16);
    expect(theme.textTheme.bodySmall?.fontSize, 13);
  });

  testWidgets('App token lookup and shared components work from App barrel', (
    tester,
  ) async {
    late YeknomAppThemeTokens resolvedTokens;
    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomAppTheme.light(preset: YeknomColorPreset.orchid),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              resolvedTokens = context.yeknomAppThemeTokens;
              return Column(
                children: [
                  YeknomButton.filled(
                    onPressed: () {},
                    label: const Text('Continue'),
                  ),
                  const YeknomTextField(
                    decoration: InputDecoration(labelText: 'Account name'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(resolvedTokens.cardRadius, 18);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(56),
    );
    expect(tester.takeException(), isNull);
  });
}

void _expectThemeContrast(
  ThemeData theme,
  YeknomAppThemeTokens tokens,
  String reason,
) {
  final scheme = theme.colorScheme;
  final textPairs = <(String, Color, Color)>[
    ('primary', scheme.primary, scheme.onPrimary),
    ('primary container', scheme.primaryContainer, scheme.onPrimaryContainer),
    ('secondary', scheme.secondary, scheme.onSecondary),
    (
      'secondary container',
      scheme.secondaryContainer,
      scheme.onSecondaryContainer,
    ),
    ('surface', scheme.surface, scheme.onSurface),
    ('surface variant text', scheme.surface, scheme.onSurfaceVariant),
    ('surface error text', scheme.surface, scheme.error),
    ('error', scheme.error, scheme.onError),
    ('error container', scheme.errorContainer, scheme.onErrorContainer),
    ('hero foreground', tokens.heroBackground, tokens.heroForeground),
    ('hero muted', tokens.heroBackground, tokens.heroMuted),
    ('hero action content', tokens.heroAction, tokens.heroForeground),
    (
      'snackbar content',
      theme.snackBarTheme.backgroundColor!,
      theme.snackBarTheme.contentTextStyle!.color!,
    ),
    (
      'snackbar action',
      theme.snackBarTheme.backgroundColor!,
      theme.snackBarTheme.actionTextColor!,
    ),
    (
      'tooltip content',
      (theme.tooltipTheme.decoration! as BoxDecoration).color!,
      theme.tooltipTheme.textStyle!.color!,
    ),
  ];

  for (final (role, background, foreground) in textPairs) {
    expect(
      _contrast(background, foreground),
      greaterThanOrEqualTo(4.5),
      reason: '$reason $role',
    );
  }
  final outlinedForeground = theme.outlinedButtonTheme.style!.foregroundColor!
      .resolve(const <WidgetState>{})!;
  final textForeground = theme.textButtonTheme.style!.foregroundColor!.resolve(
    const <WidgetState>{},
  )!;
  expect(
    _contrast(tokens.surface, outlinedForeground),
    greaterThanOrEqualTo(4.5),
    reason: '$reason outlined button',
  );
  expect(
    _contrast(tokens.surface, textForeground),
    greaterThanOrEqualTo(4.5),
    reason: '$reason text button',
  );
  expect(
    _contrast(tokens.heroBackground, tokens.heroAccent),
    greaterThanOrEqualTo(3),
    reason: '$reason hero accent',
  );
  expect(
    _contrast(tokens.surface, tokens.interactiveAccent),
    greaterThanOrEqualTo(3),
    reason: '$reason interactive accent on surface',
  );
  expect(
    _contrast(tokens.surfaceSoft, tokens.interactiveAccent),
    greaterThanOrEqualTo(3),
    reason: '$reason interactive accent on soft surface',
  );
  final enabledField =
      theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
  expect(
    _contrast(tokens.surface, enabledField.borderSide.color),
    greaterThanOrEqualTo(3),
    reason: '$reason input boundary',
  );
  final outlinedSide = theme.outlinedButtonTheme.style!.side!.resolve(
    const <WidgetState>{},
  )!;
  expect(
    _contrast(tokens.surface, outlinedSide.color),
    greaterThanOrEqualTo(3),
    reason: '$reason outlined button boundary',
  );
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
