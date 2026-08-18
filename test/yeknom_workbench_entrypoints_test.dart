import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_foundation.dart' as foundation;
import 'package:yeknom_ui_kit/yeknom_workbench.dart' as workbench;

void main() {
  test('foundation entry point exposes shared semantic tokens', () {
    final palette = foundation.YeknomPalette.fromBrightness(Brightness.light);

    expect(foundation.YeknomSpacing.md, 12);
    expect(foundation.YeknomRadii.medium, isNotNull);
    expect(foundation.YeknomTone.success.resolve(palette), palette.ack);
  });

  group('YeknomWorkbenchTheme', () {
    test('light and dark retain the original theme contract', () {
      for (final preset in foundation.YeknomColorPreset.values) {
        _expectEquivalentThemes(
          workbench.YeknomWorkbenchTheme.light(preset: preset),
          workbench.YeknomTheme.light(preset: preset),
        );
        _expectEquivalentThemes(
          workbench.YeknomWorkbenchTheme.dark(preset: preset),
          workbench.YeknomTheme.dark(preset: preset),
        );
      }
    });

    test(
      'build forwards brightness, preset and explicit palette precedence',
      () {
        final custom = foundation.YeknomPalette.fromBrightness(
          Brightness.dark,
        ).copyWith(active: const Color(0xFF123456));

        for (final brightness in Brightness.values) {
          final actual = workbench.YeknomWorkbenchTheme.build(
            brightness,
            palette: custom,
            preset: foundation.YeknomColorPreset.orchid,
          );
          final expected = workbench.YeknomTheme.build(
            brightness,
            palette: custom,
            preset: foundation.YeknomColorPreset.orchid,
          );

          _expectEquivalentThemes(actual, expected);
          expect(actual.extension<foundation.YeknomPalette>(), same(custom));
        }
      },
    );
  });
}

void _expectEquivalentThemes(ThemeData actual, ThemeData expected) {
  expect(actual.brightness, expected.brightness);
  expect(actual.colorScheme, expected.colorScheme);
  expect(actual.scaffoldBackgroundColor, expected.scaffoldBackgroundColor);
  expect(actual.canvasColor, expected.canvasColor);
  expect(actual.dividerColor, expected.dividerColor);
  expect(actual.textTheme, expected.textTheme);
  expect(actual.appBarTheme, expected.appBarTheme);
  expect(actual.cardTheme, expected.cardTheme);
  expect(actual.dialogTheme, expected.dialogTheme);
  expect(actual.inputDecorationTheme, expected.inputDecorationTheme);
  expect(actual.filledButtonTheme, expected.filledButtonTheme);
  expect(actual.outlinedButtonTheme, expected.outlinedButtonTheme);
  expect(actual.textButtonTheme, expected.textButtonTheme);
  expect(actual.segmentedButtonTheme, expected.segmentedButtonTheme);
  for (final states in <Set<WidgetState>>[
    const {},
    const {WidgetState.selected},
    const {WidgetState.disabled},
    const {WidgetState.selected, WidgetState.disabled},
  ]) {
    expect(
      actual.switchTheme.thumbColor?.resolve(states),
      expected.switchTheme.thumbColor?.resolve(states),
    );
    expect(
      actual.switchTheme.trackColor?.resolve(states),
      expected.switchTheme.trackColor?.resolve(states),
    );
    expect(
      actual.switchTheme.trackOutlineColor?.resolve(states),
      expected.switchTheme.trackOutlineColor?.resolve(states),
    );
  }
  expect(
    actual.switchTheme.materialTapTargetSize,
    expected.switchTheme.materialTapTargetSize,
  );
  expect(actual.listTileTheme, expected.listTileTheme);
  expect(actual.popupMenuTheme, expected.popupMenuTheme);

  final actualPalette = actual.extension<foundation.YeknomPalette>();
  final expectedPalette = expected.extension<foundation.YeknomPalette>();
  expect(actualPalette, isNotNull);
  expect(expectedPalette, isNotNull);
  expect(actualPalette!.dark, expectedPalette!.dark);
  expect(actualPalette.bench, expectedPalette.bench);
  expect(actualPalette.module, expectedPalette.module);
  expect(actualPalette.trace, expectedPalette.trace);
  expect(actualPalette.signal, expectedPalette.signal);
  expect(actualPalette.active, expectedPalette.active);
  expect(actualPalette.ack, expectedPalette.ack);
  expect(actualPalette.fault, expectedPalette.fault);
  expect(actualPalette.warning, expectedPalette.warning);
}
