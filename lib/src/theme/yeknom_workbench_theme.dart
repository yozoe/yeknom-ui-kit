import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import 'yeknom_theme.dart';

/// Theme entry point for Yeknom's compact management-workbench experience.
///
/// This delegates to [YeknomTheme] so the explicit Workbench entry point and
/// the original compatibility API always retain the same behavior.
abstract final class YeknomWorkbenchTheme {
  static ThemeData light({
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    return YeknomTheme.light(palette: palette, preset: preset);
  }

  static ThemeData dark({
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    return YeknomTheme.dark(palette: palette, preset: preset);
  }

  static ThemeData build(
    Brightness brightness, {
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    return YeknomTheme.build(brightness, palette: palette, preset: preset);
  }
}
