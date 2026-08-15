import 'package:flutter/material.dart';

/// Semantic colors used by the Yeknom workbench visual language.
@immutable
class YeknomPalette extends ThemeExtension<YeknomPalette> {
  const YeknomPalette({
    required this.dark,
    required this.bench,
    required this.module,
    required this.trace,
    required this.signal,
    required this.active,
    required this.ack,
    required this.fault,
    required this.warning,
    required this.onSignal,
    required this.muted,
    required this.faint,
    required this.border,
    required this.controlBorder,
    required this.field,
    required this.raised,
    required this.selected,
    required this.signalSelected,
  });

  factory YeknomPalette.fromBrightness(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bench = dark ? const Color(0xFF12191C) : const Color(0xFFF3F7F6);
    final module = dark ? const Color(0xFF1B2529) : const Color(0xFFFFFFFF);
    final trace = dark ? const Color(0xFFDCE6E3) : const Color(0xFF172326);
    final signal = dark ? const Color(0xFFE6B36A) : const Color(0xFF955811);
    final active = dark ? const Color(0xFF78B9C7) : const Color(0xFF2D7787);
    final ack = dark ? const Color(0xFF8CC7A4) : const Color(0xFF287B54);
    final fault = dark ? const Color(0xFFEF8F7E) : const Color(0xFFB94F43);
    final warning = dark ? const Color(0xFFE7AE72) : const Color(0xFF9A641E);

    return YeknomPalette(
      dark: dark,
      bench: bench,
      module: module,
      trace: trace,
      signal: signal,
      active: active,
      ack: ack,
      fault: fault,
      warning: warning,
      onSignal: dark ? const Color(0xFF2A1D0D) : Colors.white,
      muted: trace.withValues(alpha: dark ? 0.62 : 0.66),
      faint: trace.withValues(alpha: dark ? 0.42 : 0.48),
      border: trace.withValues(alpha: dark ? 0.14 : 0.13),
      controlBorder: trace.withValues(alpha: dark ? 0.32 : 0.28),
      field: Color.alphaBlend(
        trace.withValues(alpha: dark ? 0.035 : 0.025),
        module,
      ),
      raised: Color.alphaBlend(
        trace.withValues(alpha: dark ? 0.065 : 0.04),
        module,
      ),
      selected: Color.alphaBlend(
        active.withValues(alpha: dark ? 0.14 : 0.1),
        module,
      ),
      signalSelected: Color.alphaBlend(
        signal.withValues(alpha: dark ? 0.12 : 0.09),
        module,
      ),
    );
  }

  /// Resolves the palette attached to [ThemeData], with a brightness fallback.
  static YeknomPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<YeknomPalette>() ??
        YeknomPalette.fromBrightness(theme.brightness);
  }

  final bool dark;
  final Color bench;
  final Color module;
  final Color trace;
  final Color signal;
  final Color active;
  final Color ack;
  final Color fault;
  final Color warning;
  final Color onSignal;
  final Color muted;
  final Color faint;
  final Color border;
  final Color controlBorder;
  final Color field;
  final Color raised;
  final Color selected;
  final Color signalSelected;

  @override
  YeknomPalette copyWith({
    bool? dark,
    Color? bench,
    Color? module,
    Color? trace,
    Color? signal,
    Color? active,
    Color? ack,
    Color? fault,
    Color? warning,
    Color? onSignal,
    Color? muted,
    Color? faint,
    Color? border,
    Color? controlBorder,
    Color? field,
    Color? raised,
    Color? selected,
    Color? signalSelected,
  }) {
    return YeknomPalette(
      dark: dark ?? this.dark,
      bench: bench ?? this.bench,
      module: module ?? this.module,
      trace: trace ?? this.trace,
      signal: signal ?? this.signal,
      active: active ?? this.active,
      ack: ack ?? this.ack,
      fault: fault ?? this.fault,
      warning: warning ?? this.warning,
      onSignal: onSignal ?? this.onSignal,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      border: border ?? this.border,
      controlBorder: controlBorder ?? this.controlBorder,
      field: field ?? this.field,
      raised: raised ?? this.raised,
      selected: selected ?? this.selected,
      signalSelected: signalSelected ?? this.signalSelected,
    );
  }

  @override
  YeknomPalette lerp(covariant YeknomPalette? other, double t) {
    if (other == null) return this;
    return YeknomPalette(
      dark: t < 0.5 ? dark : other.dark,
      bench: Color.lerp(bench, other.bench, t)!,
      module: Color.lerp(module, other.module, t)!,
      trace: Color.lerp(trace, other.trace, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      active: Color.lerp(active, other.active, t)!,
      ack: Color.lerp(ack, other.ack, t)!,
      fault: Color.lerp(fault, other.fault, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onSignal: Color.lerp(onSignal, other.onSignal, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      border: Color.lerp(border, other.border, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      field: Color.lerp(field, other.field, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      signalSelected: Color.lerp(signalSelected, other.signalSelected, t)!,
    );
  }
}

extension YeknomPaletteBuildContext on BuildContext {
  /// The nearest [YeknomPalette].
  YeknomPalette get yeknomPalette => YeknomPalette.of(this);
}
