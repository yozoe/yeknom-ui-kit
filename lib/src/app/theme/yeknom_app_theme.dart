import 'package:flutter/material.dart';

import '../../foundation/yeknom_palette.dart';
import '../foundation/yeknom_app_theme_tokens.dart';

/// Theme entry point for Yeknom's spacious user-facing App experience.
///
/// App themes share [YeknomPalette] and [YeknomColorPreset] with Workbench
/// themes, but are built independently from a clean Material 3 base.
abstract final class YeknomAppTheme {
  static const _minimumContrast = 4.5;

  static ThemeData light({
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    return build(Brightness.light, palette: palette, preset: preset);
  }

  static ThemeData dark({
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    return build(Brightness.dark, palette: palette, preset: preset);
  }

  /// Builds an App theme from [preset] or an explicit [palette].
  ///
  /// When both are supplied, [palette] takes precedence. The resolved palette
  /// and [YeknomAppThemeTokens] are always attached as theme extensions.
  static ThemeData build(
    Brightness brightness, {
    YeknomPalette? palette,
    YeknomColorPreset preset = YeknomColorPreset.workbench,
  }) {
    const darkInk = Color(0xFF111719);
    const darkErrorInk = Color(0xFF321217);
    final resolvedPalette =
        palette ?? YeknomPalette.fromPreset(preset, brightness);
    final dark = brightness == Brightness.dark;
    final base = ThemeData(useMaterial3: true, brightness: brightness);
    final onPrimary = _onColor(resolvedPalette.active, darkColor: darkInk);
    final onSecondary = _onColor(
      resolvedPalette.signal,
      darkColor: const Color(0xFF21170E),
    );
    final canvas = resolvedPalette.bench;
    final surface = resolvedPalette.module;
    final contentInk = _ensureContrast(
      preferred: resolvedPalette.trace,
      fallback: _onColor(surface, darkColor: darkInk),
      against: surface,
    );
    final surfaceSoft = Color.alphaBlend(
      contentInk.withValues(alpha: dark ? 0.05 : 0.032),
      surface,
    );
    final shadowColor = Colors.black.withValues(alpha: dark ? 0.24 : 0.07);
    final primaryContainer = Color.alphaBlend(
      resolvedPalette.active.withValues(alpha: dark ? 0.14 : 0.08),
      surface,
    );
    final onPrimaryContainer = _ensureContrast(
      preferred: resolvedPalette.active,
      fallback: _onColor(primaryContainer, darkColor: darkInk),
      against: primaryContainer,
    );
    final secondaryContainer = Color.alphaBlend(
      resolvedPalette.signal.withValues(alpha: dark ? 0.12 : 0.07),
      surface,
    );
    final onSecondaryContainer = _ensureContrast(
      preferred: resolvedPalette.signal,
      fallback: _onColor(
        secondaryContainer,
        darkColor: const Color(0xFF21170E),
      ),
      against: secondaryContainer,
    );
    final onSurfaceVariant = _ensureContrast(
      preferred: Color.alphaBlend(resolvedPalette.muted, surface),
      fallback: contentInk,
      against: surface,
    );
    final accentOnSurface = _ensureContrast(
      preferred: resolvedPalette.active,
      fallback: contentInk,
      against: surface,
    );
    final interactiveAccent = _ensureContrastAgainstAll(
      preferred: resolvedPalette.active,
      fallback: contentInk,
      backgrounds: [surface, surfaceSoft],
      minimum: 3,
    );
    final onInteractiveAccent = _onColor(interactiveAccent, darkColor: darkInk);
    final controlOutline = _ensureContrast(
      preferred: Color.alphaBlend(resolvedPalette.controlBorder, surface),
      fallback: contentInk,
      against: surface,
      minimum: 3,
    );
    final error = _ensureContrast(
      preferred: resolvedPalette.fault,
      fallback: _onColor(surface, darkColor: darkErrorInk),
      against: surface,
    );
    final errorContainer = Color.alphaBlend(
      error.withValues(alpha: dark ? 0.16 : 0.1),
      surface,
    );
    final onError = _onColor(error, darkColor: darkErrorInk);
    final onErrorContainer = _ensureContrast(
      preferred: error,
      fallback: _onColor(errorContainer, darkColor: darkErrorInk),
      against: errorContainer,
    );
    final proposedHeroBase = dark
        ? Color.lerp(resolvedPalette.bench, resolvedPalette.module, 0.55)!
        : resolvedPalette.trace;
    final neutralHeroBase =
        ThemeData.estimateBrightnessForColor(proposedHeroBase) ==
            Brightness.dark
        ? proposedHeroBase
        : darkInk;
    final heroBackground = Color.alphaBlend(
      resolvedPalette.active.withValues(alpha: dark ? 0.08 : 0.1),
      neutralHeroBase,
    );
    final heroForeground = _ensureContrast(
      preferred: dark ? contentInk : surface,
      fallback: _onColor(heroBackground, darkColor: darkInk),
      against: heroBackground,
    );
    final heroMuted = _ensureContrast(
      preferred: Color.alphaBlend(
        heroForeground.withValues(alpha: 0.7),
        heroBackground,
      ),
      fallback: heroForeground,
      against: heroBackground,
    );
    final heroAccent = _ensureContrast(
      preferred: resolvedPalette.active,
      fallback: heroForeground,
      against: heroBackground,
      minimum: 3,
    );
    final heroAction = _ensureContrast(
      preferred: Color.alphaBlend(
        heroForeground.withValues(alpha: 0.08),
        heroBackground,
      ),
      fallback: heroBackground,
      against: heroForeground,
    );
    final snackBarAction = _ensureContrast(
      preferred: resolvedPalette.active,
      fallback: heroForeground,
      against: heroBackground,
    );
    final scheme =
        ColorScheme.fromSeed(
          seedColor: resolvedPalette.active,
          brightness: brightness,
        ).copyWith(
          primary: resolvedPalette.active,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondary: resolvedPalette.signal,
          onSecondary: onSecondary,
          secondaryContainer: secondaryContainer,
          onSecondaryContainer: onSecondaryContainer,
          surface: surface,
          onSurface: contentInk,
          onSurfaceVariant: onSurfaceVariant,
          surfaceContainerLowest: canvas,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: surfaceSoft,
          surfaceContainerHighest: resolvedPalette.raised,
          outline: controlOutline,
          outlineVariant: resolvedPalette.border,
          shadow: shadowColor,
          scrim: Colors.black,
          error: error,
          onError: onError,
          errorContainer: errorContainer,
          onErrorContainer: onErrorContainer,
        );
    final tokens = YeknomAppThemeTokens(
      canvas: canvas,
      surface: surface,
      surfaceSoft: surfaceSoft,
      shadowColor: shadowColor,
      interactiveAccent: interactiveAccent,
      heroBackground: heroBackground,
      heroForeground: heroForeground,
      heroMuted: heroMuted,
      heroAccent: heroAccent,
      heroAction: heroAction,
    );
    final textTheme = base.textTheme
        .apply(bodyColor: contentInk, displayColor: contentInk)
        .copyWith(
          displaySmall: base.textTheme.displaySmall?.copyWith(
            color: contentInk,
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            color: contentInk,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            color: contentInk,
            fontSize: 22,
            height: 1.28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            color: contentInk,
            fontSize: 17,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: base.textTheme.titleSmall?.copyWith(
            color: contentInk,
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            color: contentInk,
            fontSize: 16,
            height: 1.5,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            color: contentInk,
            fontSize: 14,
            height: 1.5,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            color: onSurfaceVariant,
            fontSize: 13,
            height: 1.45,
          ),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            color: contentInk,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: base.textTheme.labelMedium?.copyWith(
            color: onSurfaceVariant,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.controlRadius),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.cardRadius),
      side: BorderSide(color: resolvedPalette.border),
    );
    final modalShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.modalRadius),
      side: BorderSide(color: resolvedPalette.border),
    );
    final sheetShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.modalRadius),
      ),
    );
    final menuShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.controlRadius),
      side: BorderSide(color: resolvedPalette.border),
    );
    final restingFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.controlRadius),
      borderSide: BorderSide(color: controlOutline),
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[resolvedPalette, tokens],
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.canvas,
      canvasColor: tokens.surface,
      cardColor: tokens.surface,
      shadowColor: tokens.shadowColor,
      dividerColor: resolvedPalette.border,
      disabledColor: resolvedPalette.faint,
      focusColor: interactiveAccent.withValues(alpha: 0.12),
      hoverColor: interactiveAccent.withValues(alpha: 0.07),
      highlightColor: interactiveAccent.withValues(alpha: 0.09),
      splashColor: interactiveAccent.withValues(alpha: 0.1),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: textTheme,
      iconTheme: base.iconTheme.copyWith(color: onSurfaceVariant, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.canvas,
        foregroundColor: contentInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: tokens.pageGutter,
        iconTheme: IconThemeData(color: contentInk, size: 24),
        actionsIconTheme: IconThemeData(color: contentInk, size: 24),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.shadowColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: cardShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.shadowColor,
        elevation: dark ? 4 : 8,
        shape: modalShape,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 560),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        barrierColor: scheme.scrim.withValues(alpha: 0.48),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        modalBackgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.shadowColor,
        elevation: 0,
        modalElevation: dark ? 4 : 8,
        modalBarrierColor: scheme.scrim.withValues(alpha: 0.48),
        shape: sheetShape,
        showDragHandle: true,
        dragHandleColor: controlOutline,
        dragHandleSize: const Size(36, 4),
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: accentOnSurface,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: restingFieldBorder,
        enabledBorder: restingFieldBorder,
        disabledBorder: restingFieldBorder.copyWith(
          borderSide: BorderSide(color: resolvedPalette.border),
        ),
        focusedBorder: restingFieldBorder.copyWith(
          borderSide: BorderSide(color: interactiveAccent, width: 1.8),
        ),
        errorBorder: restingFieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: restingFieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: interactiveAccent,
          foregroundColor: onInteractiveAccent,
          elevation: 0,
          minimumSize: Size(
            tokens.minimumTapTarget,
            tokens.primaryButtonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.surface,
          foregroundColor: accentOnSurface,
          disabledForegroundColor: resolvedPalette.faint,
          disabledBackgroundColor: tokens.surfaceSoft,
          side: BorderSide(color: controlOutline),
          minimumSize: Size(
            tokens.minimumTapTarget,
            tokens.primaryButtonHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentOnSurface,
          minimumSize: Size.square(tokens.minimumTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge,
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: contentInk,
          disabledForegroundColor: resolvedPalette.faint,
          minimumSize: Size.square(tokens.minimumTapTarget),
          padding: const EdgeInsets.all(12),
          shape: controlShape,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: tokens.shadowColor,
        elevation: 0,
        indicatorColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius - 4),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? accentOnSurface
                : onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? accentOnSurface
                : onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        useIndicator: true,
        indicatorColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius - 4),
        ),
        selectedIconTheme: IconThemeData(color: accentOnSurface, size: 24),
        unselectedIconTheme: IconThemeData(color: onSurfaceVariant, size: 24),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: accentOnSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium,
        minWidth: 72,
        minExtendedWidth: 220,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: contentInk,
        selectedColor: scheme.onPrimaryContainer,
        selectedTileColor: scheme.primaryContainer,
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        horizontalTitleGap: 12,
        shape: controlShape,
      ),
      switchTheme: SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return resolvedPalette.faint;
          }
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return tokens.surfaceSoft;
          }
          if (states.contains(WidgetState.selected)) {
            return interactiveAccent;
          }
          return tokens.surfaceSoft;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return controlOutline;
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: dark ? 3 : 6,
        shadowColor: tokens.shadowColor,
        shape: menuShape,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.heroBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.heroForeground,
        ),
        actionTextColor: snackBarAction,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: controlShape,
        insetPadding: const EdgeInsets.all(16),
      ),
      dividerTheme: DividerThemeData(
        color: resolvedPalette.border,
        space: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: tokens.heroBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: tokens.heroForeground),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: interactiveAccent,
        linearTrackColor: tokens.surfaceSoft,
        circularTrackColor: tokens.surfaceSoft,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: interactiveAccent,
        selectionColor: interactiveAccent.withValues(alpha: 0.22),
        selectionHandleColor: interactiveAccent,
      ),
    );
  }

  static Color _onColor(Color background, {required Color darkColor}) {
    final lightContrast = _contrast(Colors.white, background);
    final darkContrast = _contrast(darkColor, background);
    final brandCandidate = lightContrast >= darkContrast
        ? Colors.white
        : darkColor;
    if (_contrast(brandCandidate, background) >= _minimumContrast) {
      return brandCandidate;
    }

    final blackContrast = _contrast(Colors.black, background);
    return blackContrast >= lightContrast ? Colors.black : Colors.white;
  }

  static Color _ensureContrast({
    required Color preferred,
    required Color fallback,
    required Color against,
    double minimum = _minimumContrast,
  }) {
    if (_contrast(preferred, against) >= minimum) return preferred;
    for (var percentage = 1; percentage <= 100; percentage += 1) {
      final candidate = Color.lerp(preferred, fallback, percentage / 100)!;
      if (_contrast(candidate, against) >= minimum) return candidate;
    }
    if (_contrast(fallback, against) >= minimum) return fallback;
    return _onColor(against, darkColor: Colors.black);
  }

  static Color _ensureContrastAgainstAll({
    required Color preferred,
    required Color fallback,
    required List<Color> backgrounds,
    required double minimum,
  }) {
    for (var percentage = 0; percentage <= 100; percentage += 1) {
      final candidate = Color.lerp(preferred, fallback, percentage / 100)!;
      if (backgrounds.every(
        (background) => _contrast(candidate, background) >= minimum,
      )) {
        return candidate;
      }
    }
    return fallback;
  }

  static double _contrast(Color first, Color second) {
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
}
