import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';

abstract final class YeknomTheme {
  static ThemeData light({YeknomPalette? palette}) {
    return build(Brightness.light, palette: palette);
  }

  static ThemeData dark({YeknomPalette? palette}) {
    return build(Brightness.dark, palette: palette);
  }

  static ThemeData build(Brightness brightness, {YeknomPalette? palette}) {
    final resolvedPalette = palette ?? YeknomPalette.fromBrightness(brightness);
    final dark = brightness == Brightness.dark;
    final base = ThemeData(useMaterial3: true, brightness: brightness);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: resolvedPalette.active,
          brightness: brightness,
        ).copyWith(
          primary: resolvedPalette.active,
          onPrimary:
              ThemeData.estimateBrightnessForColor(resolvedPalette.active) ==
                  Brightness.dark
              ? Colors.white
              : const Color(0xFF102226),
          primaryContainer: resolvedPalette.selected,
          onPrimaryContainer: resolvedPalette.trace,
          secondary: resolvedPalette.signal,
          onSecondary: resolvedPalette.onSignal,
          secondaryContainer: resolvedPalette.signalSelected,
          onSecondaryContainer: resolvedPalette.trace,
          surface: resolvedPalette.module,
          onSurface: resolvedPalette.trace,
          surfaceContainerLowest: resolvedPalette.bench,
          surfaceContainerLow: resolvedPalette.bench,
          surfaceContainer: resolvedPalette.module,
          surfaceContainerHigh: resolvedPalette.field,
          surfaceContainerHighest: resolvedPalette.raised,
          outline: resolvedPalette.controlBorder,
          outlineVariant: resolvedPalette.border,
          error: resolvedPalette.fault,
          onError:
              ThemeData.estimateBrightnessForColor(resolvedPalette.fault) ==
                  Brightness.dark
              ? Colors.white
              : const Color(0xFF32120D),
          errorContainer: resolvedPalette.fault.withValues(
            alpha: dark ? 0.14 : 0.1,
          ),
          onErrorContainer: resolvedPalette.fault,
        );
    final textTheme = base.textTheme
        .apply(
          bodyColor: resolvedPalette.trace,
          displayColor: resolvedPalette.trace,
        )
        .copyWith(
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            color: resolvedPalette.trace,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            color: resolvedPalette.trace,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            color: resolvedPalette.trace,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: base.textTheme.titleSmall?.copyWith(
            color: resolvedPalette.trace,
            fontWeight: FontWeight.w600,
          ),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            color: resolvedPalette.muted,
          ),
          labelMedium: base.textTheme.labelMedium?.copyWith(
            color: resolvedPalette.muted,
            fontWeight: FontWeight.w600,
          ),
        );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: BorderSide(color: resolvedPalette.controlBorder),
    );
    final compactShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9),
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[resolvedPalette],
      colorScheme: scheme,
      scaffoldBackgroundColor: resolvedPalette.bench,
      canvasColor: resolvedPalette.module,
      dividerColor: resolvedPalette.border,
      textTheme: textTheme,
      iconTheme: base.iconTheme.copyWith(
        color: resolvedPalette.muted,
        size: 19,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: resolvedPalette.module,
        foregroundColor: resolvedPalette.trace,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 66,
        titleSpacing: 14,
        shape: Border(bottom: BorderSide(color: resolvedPalette.border)),
        titleTextStyle: TextStyle(
          color: resolvedPalette.trace,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: resolvedPalette.module,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: resolvedPalette.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: resolvedPalette.module,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: resolvedPalette.border),
        ),
        titleTextStyle: TextStyle(
          color: resolvedPalette.trace,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: resolvedPalette.trace,
          fontSize: 13,
          height: 1.45,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: resolvedPalette.border,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: resolvedPalette.field,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        labelStyle: TextStyle(color: resolvedPalette.muted, fontSize: 12),
        hintStyle: TextStyle(color: resolvedPalette.faint, fontSize: 12),
        prefixIconColor: resolvedPalette.muted,
        suffixIconColor: resolvedPalette.muted,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: resolvedPalette.border),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: resolvedPalette.active, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: resolvedPalette.fault),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: resolvedPalette.fault, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          shape: compactShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: resolvedPalette.controlBorder),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: compactShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: compactShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: resolvedPalette.muted,
          disabledForegroundColor: resolvedPalette.faint.withValues(alpha: 0.6),
          shape: compactShape,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStatePropertyAll(compactShape),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: resolvedPalette.field,
        selectedColor: resolvedPalette.selected,
        disabledColor: resolvedPalette.field.withValues(alpha: 0.55),
        side: BorderSide(color: resolvedPalette.border),
        labelStyle: TextStyle(color: resolvedPalette.trace, fontSize: 11.5),
        secondaryLabelStyle: TextStyle(
          color: resolvedPalette.active,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: resolvedPalette.active,
        shape: compactShape,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: resolvedPalette.muted,
        textColor: resolvedPalette.trace,
        selectedColor: resolvedPalette.active,
        selectedTileColor: resolvedPalette.selected,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: resolvedPalette.module,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: resolvedPalette.border),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF303B3F) : const Color(0xFF263235),
          borderRadius: BorderRadius.circular(7),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
        waitDuration: const Duration(milliseconds: 450),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: resolvedPalette.field,
        circularTrackColor: resolvedPalette.field,
      ),
      scrollbarTheme: base.scrollbarTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(resolvedPalette.controlBorder),
        radius: const Radius.circular(999),
        thickness: const WidgetStatePropertyAll(5),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: resolvedPalette.active,
        selectionColor: resolvedPalette.active.withValues(alpha: 0.22),
        selectionHandleColor: resolvedPalette.active,
      ),
    );
  }
}
