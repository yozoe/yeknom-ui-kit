import 'package:flutter/material.dart';

/// Curated color combinations for Yeknom desktop tools.
///
/// Brightness is intentionally independent from the preset: every preset has
/// a light and dark palette so applications can still follow the system theme.
enum YeknomColorPreset {
  workbench,
  cobalt,
  orchid,
  graphite,
  obsidian,
  midnight,
  blackberry,
  sage,
}

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

  /// Builds the original Yeknom workbench palette.
  ///
  /// This remains the default for backwards compatibility. New code that
  /// exposes a color preference can use [YeknomPalette.fromPreset].
  factory YeknomPalette.fromBrightness(Brightness brightness) {
    return YeknomPalette.fromPreset(YeknomColorPreset.workbench, brightness);
  }

  /// Builds a semantic palette from a curated color [preset].
  factory YeknomPalette.fromPreset(
    YeknomColorPreset preset,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    final colors = switch (preset) {
      YeknomColorPreset.workbench =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF12191C),
                module: Color(0xFF1B2529),
                trace: Color(0xFFDCE6E3),
                signal: Color(0xFFE6B36A),
                active: Color(0xFF78B9C7),
                ack: Color(0xFF8CC7A4),
                fault: Color(0xFFEF8F7E),
                warning: Color(0xFFE7AE72),
              )
            : const _PaletteCore(
                bench: Color(0xFFF3F7F6),
                module: Color(0xFFFFFFFF),
                trace: Color(0xFF172326),
                signal: Color(0xFF955811),
                active: Color(0xFF2D7787),
                ack: Color(0xFF287B54),
                fault: Color(0xFFB94F43),
                warning: Color(0xFF9A641E),
              ),
      YeknomColorPreset.cobalt =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF111820),
                module: Color(0xFF19232D),
                trace: Color(0xFFDEE7F2),
                signal: Color(0xFFE7B06A),
                active: Color(0xFF78AAE0),
                ack: Color(0xFF88C7A1),
                fault: Color(0xFFED9189),
                warning: Color(0xFFE6AD70),
              )
            : const _PaletteCore(
                bench: Color(0xFFF3F6FA),
                module: Color(0xFFFFFFFF),
                trace: Color(0xFF17202D),
                signal: Color(0xFF955A13),
                active: Color(0xFF285F9E),
                ack: Color(0xFF287A55),
                fault: Color(0xFFB64D46),
                warning: Color(0xFF95611D),
              ),
      YeknomColorPreset.orchid =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF18141D),
                module: Color(0xFF231D29),
                trace: Color(0xFFE9E0EC),
                signal: Color(0xFFE78DB7),
                active: Color(0xFFB8A0E2),
                ack: Color(0xFF8BC7A5),
                fault: Color(0xFFEF938A),
                warning: Color(0xFFE8B172),
              )
            : const _PaletteCore(
                bench: Color(0xFFF6F3F8),
                module: Color(0xFFFFFDFF),
                trace: Color(0xFF261D2B),
                signal: Color(0xFF963E6B),
                active: Color(0xFF684BA5),
                ack: Color(0xFF2D7957),
                fault: Color(0xFFB64E47),
                warning: Color(0xFF95621D),
              ),
      YeknomColorPreset.graphite =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF141617),
                module: Color(0xFF202426),
                trace: Color(0xFFE3E7E7),
                signal: Color(0xFFE99A77),
                active: Color(0xFF9CBAC1),
                ack: Color(0xFF8BC6A2),
                fault: Color(0xFFEE9187),
                warning: Color(0xFFE5AE70),
              )
            : const _PaletteCore(
                bench: Color(0xFFF4F5F5),
                module: Color(0xFFFFFFFF),
                trace: Color(0xFF202425),
                signal: Color(0xFF9A4B30),
                active: Color(0xFF526B72),
                ack: Color(0xFF2B7854),
                fault: Color(0xFFB54E46),
                warning: Color(0xFF93611D),
              ),
      YeknomColorPreset.obsidian =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF070A0B),
                module: Color(0xFF101617),
                trace: Color(0xFFDFE8E8),
                signal: Color(0xFFDDAA5F),
                active: Color(0xFF67BCC0),
                ack: Color(0xFF82C39A),
                fault: Color(0xFFEC8A80),
                warning: Color(0xFFDEAA68),
              )
            : const _PaletteCore(
                bench: Color(0xFFF0F4F3),
                module: Color(0xFFFCFEFD),
                trace: Color(0xFF142021),
                signal: Color(0xFF8D5813),
                active: Color(0xFF246B70),
                ack: Color(0xFF277850),
                fault: Color(0xFFB44D45),
                warning: Color(0xFF92601C),
              ),
      YeknomColorPreset.midnight =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF070A11),
                module: Color(0xFF101621),
                trace: Color(0xFFE2E9F5),
                signal: Color(0xFF70C3D1),
                active: Color(0xFF85A9EB),
                ack: Color(0xFF82C49A),
                fault: Color(0xFFEC8C83),
                warning: Color(0xFFE0AC69),
              )
            : const _PaletteCore(
                bench: Color(0xFFF1F4F9),
                module: Color(0xFFFCFDFF),
                trace: Color(0xFF151E2C),
                signal: Color(0xFF176D7B),
                active: Color(0xFF345F9F),
                ack: Color(0xFF287852),
                fault: Color(0xFFB44E47),
                warning: Color(0xFF93611D),
              ),
      YeknomColorPreset.blackberry =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF0B080D),
                module: Color(0xFF151018),
                trace: Color(0xFFEAE2EC),
                signal: Color(0xFFE18CB5),
                active: Color(0xFFB69AE1),
                ack: Color(0xFF85C29C),
                fault: Color(0xFFEC8D84),
                warning: Color(0xFFE1AC6A),
              )
            : const _PaletteCore(
                bench: Color(0xFFF5F1F6),
                module: Color(0xFFFFFBFF),
                trace: Color(0xFF251A29),
                signal: Color(0xFF913D68),
                active: Color(0xFF69479C),
                ack: Color(0xFF2B7753),
                fault: Color(0xFFB44E47),
                warning: Color(0xFF93611D),
              ),
      YeknomColorPreset.sage =>
        dark
            ? const _PaletteCore(
                bench: Color(0xFF111610),
                module: Color(0xFF1B2319),
                trace: Color(0xFFD9E2D3),
                signal: Color(0xFFD1B176),
                active: Color(0xFF8FB7BE),
                ack: Color(0xFF91C39C),
                fault: Color(0xFFE49186),
                warning: Color(0xFFDAB574),
              )
            : const _PaletteCore(
                bench: Color(0xFFE9EEE4),
                module: Color(0xFFF5F7EF),
                trace: Color(0xFF263128),
                signal: Color(0xFF826238),
                active: Color(0xFF466C72),
                ack: Color(0xFF356B4C),
                fault: Color(0xFFA85049),
                warning: Color(0xFF86632A),
              ),
    };

    return YeknomPalette(
      dark: dark,
      bench: colors.bench,
      module: colors.module,
      trace: colors.trace,
      signal: colors.signal,
      active: colors.active,
      ack: colors.ack,
      fault: colors.fault,
      warning: colors.warning,
      onSignal: preset == YeknomColorPreset.workbench
          ? dark
                ? const Color(0xFF2A1D0D)
                : Colors.white
          : ThemeData.estimateBrightnessForColor(colors.signal) ==
                Brightness.dark
          ? Colors.white
          : const Color(0xFF21170E),
      muted: colors.trace.withValues(alpha: dark ? 0.62 : 0.68),
      faint: colors.trace.withValues(alpha: dark ? 0.42 : 0.48),
      border: colors.trace.withValues(alpha: dark ? 0.14 : 0.13),
      controlBorder: colors.trace.withValues(alpha: dark ? 0.32 : 0.28),
      field: Color.alphaBlend(
        colors.trace.withValues(alpha: dark ? 0.035 : 0.025),
        colors.module,
      ),
      raised: Color.alphaBlend(
        colors.trace.withValues(alpha: dark ? 0.065 : 0.04),
        colors.module,
      ),
      selected: Color.alphaBlend(
        colors.active.withValues(alpha: dark ? 0.14 : 0.1),
        colors.module,
      ),
      signalSelected: Color.alphaBlend(
        colors.signal.withValues(alpha: dark ? 0.12 : 0.09),
        colors.module,
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

@immutable
class _PaletteCore {
  const _PaletteCore({
    required this.bench,
    required this.module,
    required this.trace,
    required this.signal,
    required this.active,
    required this.ack,
    required this.fault,
    required this.warning,
  });

  final Color bench;
  final Color module;
  final Color trace;
  final Color signal;
  final Color active;
  final Color ack;
  final Color fault;
  final Color warning;
}
