import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Layout and surface tokens for Yeknom's spacious user-facing App experience.
///
/// App components should read this extension together with [ColorScheme]. They
/// must not depend directly on the Workbench-oriented palette.
@immutable
class YeknomAppThemeTokens extends ThemeExtension<YeknomAppThemeTokens> {
  const YeknomAppThemeTokens({
    this.contentMaxWidth = 1120,
    this.cardRadius = 18,
    this.heroRadius = 24,
    this.controlRadius = 14,
    this.modalRadius = 22,
    this.minimumTapTarget = 48,
    this.primaryButtonHeight = 56,
    this.pageGutter = 20,
    required this.canvas,
    required this.surface,
    required this.surfaceSoft,
    required this.shadowColor,
    required this.interactiveAccent,
    required this.heroBackground,
    required this.heroForeground,
    required this.heroMuted,
    required this.heroAccent,
    required this.heroAction,
  });

  /// Creates a resilient fallback from a Material color scheme.
  ///
  /// [YeknomAppTheme] always attaches explicit tokens. This factory keeps
  /// standalone App components usable under a host-provided Material theme.
  factory YeknomAppThemeTokens.fromColorScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final neutralHeroBase = dark
        ? Color.lerp(scheme.surfaceContainerLowest, scheme.surface, 0.55)!
        : scheme.onSurface;
    final heroBackground = Color.alphaBlend(
      scheme.primary.withValues(alpha: dark ? 0.08 : 0.1),
      neutralHeroBase,
    );
    final heroForeground = _readableColor(
      preferred: dark ? scheme.onSurface : scheme.surface,
      against: heroBackground,
    );
    final heroMuted = _ensureTokenContrast(
      preferred: Color.alphaBlend(
        heroForeground.withValues(alpha: 0.7),
        heroBackground,
      ),
      fallback: heroForeground,
      against: heroBackground,
    );
    final heroAccent = _ensureTokenContrast(
      preferred: scheme.primary,
      fallback: heroForeground,
      against: heroBackground,
      minimum: 3,
    );
    final heroAction = _ensureTokenContrast(
      preferred: Color.alphaBlend(
        heroForeground.withValues(alpha: 0.08),
        heroBackground,
      ),
      fallback: heroBackground,
      against: heroForeground,
    );
    final interactiveAccent = _ensureTokenContrastAcross(
      preferred: scheme.primary,
      fallback: scheme.onSurface,
      backgrounds: [scheme.surface, scheme.surfaceContainerHigh],
      minimum: 3,
    );

    return YeknomAppThemeTokens(
      canvas: scheme.surfaceContainerLowest,
      surface: scheme.surface,
      surfaceSoft: scheme.surfaceContainerHigh,
      shadowColor: scheme.shadow.withValues(alpha: dark ? 0.24 : 0.07),
      interactiveAccent: interactiveAccent,
      heroBackground: heroBackground,
      heroForeground: heroForeground,
      heroMuted: heroMuted,
      heroAccent: heroAccent,
      heroAction: heroAction,
    );
  }

  static YeknomAppThemeTokens of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<YeknomAppThemeTokens>() ??
        YeknomAppThemeTokens.fromColorScheme(theme.colorScheme);
  }

  final double contentMaxWidth;
  final double cardRadius;
  final double heroRadius;
  final double controlRadius;
  final double modalRadius;
  final double minimumTapTarget;
  final double primaryButtonHeight;
  final double pageGutter;

  final Color canvas;
  final Color surface;
  final Color surfaceSoft;
  final Color shadowColor;
  final Color interactiveAccent;
  final Color heroBackground;
  final Color heroForeground;
  final Color heroMuted;
  final Color heroAccent;
  final Color heroAction;

  @override
  YeknomAppThemeTokens copyWith({
    double? contentMaxWidth,
    double? cardRadius,
    double? heroRadius,
    double? controlRadius,
    double? modalRadius,
    double? minimumTapTarget,
    double? primaryButtonHeight,
    double? pageGutter,
    Color? canvas,
    Color? surface,
    Color? surfaceSoft,
    Color? shadowColor,
    Color? interactiveAccent,
    Color? heroBackground,
    Color? heroForeground,
    Color? heroMuted,
    Color? heroAccent,
    Color? heroAction,
  }) {
    return YeknomAppThemeTokens(
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      cardRadius: cardRadius ?? this.cardRadius,
      heroRadius: heroRadius ?? this.heroRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      modalRadius: modalRadius ?? this.modalRadius,
      minimumTapTarget: minimumTapTarget ?? this.minimumTapTarget,
      primaryButtonHeight: primaryButtonHeight ?? this.primaryButtonHeight,
      pageGutter: pageGutter ?? this.pageGutter,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      shadowColor: shadowColor ?? this.shadowColor,
      interactiveAccent: interactiveAccent ?? this.interactiveAccent,
      heroBackground: heroBackground ?? this.heroBackground,
      heroForeground: heroForeground ?? this.heroForeground,
      heroMuted: heroMuted ?? this.heroMuted,
      heroAccent: heroAccent ?? this.heroAccent,
      heroAction: heroAction ?? this.heroAction,
    );
  }

  @override
  YeknomAppThemeTokens lerp(covariant YeknomAppThemeTokens? other, double t) {
    if (other == null) return this;
    return YeknomAppThemeTokens(
      contentMaxWidth:
          lerpDouble(contentMaxWidth, other.contentMaxWidth, t) ??
          contentMaxWidth,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      heroRadius: lerpDouble(heroRadius, other.heroRadius, t) ?? heroRadius,
      controlRadius:
          lerpDouble(controlRadius, other.controlRadius, t) ?? controlRadius,
      modalRadius: lerpDouble(modalRadius, other.modalRadius, t) ?? modalRadius,
      minimumTapTarget:
          lerpDouble(minimumTapTarget, other.minimumTapTarget, t) ??
          minimumTapTarget,
      primaryButtonHeight:
          lerpDouble(primaryButtonHeight, other.primaryButtonHeight, t) ??
          primaryButtonHeight,
      pageGutter: lerpDouble(pageGutter, other.pageGutter, t) ?? pageGutter,
      canvas: Color.lerp(canvas, other.canvas, t) ?? canvas,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t) ?? surfaceSoft,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      interactiveAccent:
          Color.lerp(interactiveAccent, other.interactiveAccent, t) ??
          interactiveAccent,
      heroBackground:
          Color.lerp(heroBackground, other.heroBackground, t) ?? heroBackground,
      heroForeground:
          Color.lerp(heroForeground, other.heroForeground, t) ?? heroForeground,
      heroMuted: Color.lerp(heroMuted, other.heroMuted, t) ?? heroMuted,
      heroAccent: Color.lerp(heroAccent, other.heroAccent, t) ?? heroAccent,
      heroAction: Color.lerp(heroAction, other.heroAction, t) ?? heroAction,
    );
  }
}

extension YeknomAppThemeTokensBuildContext on BuildContext {
  YeknomAppThemeTokens get yeknomAppThemeTokens =>
      YeknomAppThemeTokens.of(this);
}

Color _readableColor({
  required Color preferred,
  required Color against,
  double minimum = 4.5,
}) {
  if (_tokenContrast(preferred, against) >= minimum) return preferred;
  final whiteContrast = _tokenContrast(Colors.white, against);
  final blackContrast = _tokenContrast(Colors.black, against);
  return whiteContrast >= blackContrast ? Colors.white : Colors.black;
}

Color _ensureTokenContrast({
  required Color preferred,
  required Color fallback,
  required Color against,
  double minimum = 4.5,
}) {
  if (_tokenContrast(preferred, against) >= minimum) return preferred;
  for (var percentage = 1; percentage <= 100; percentage += 1) {
    final candidate = Color.lerp(preferred, fallback, percentage / 100)!;
    if (_tokenContrast(candidate, against) >= minimum) return candidate;
  }
  return _readableColor(
    preferred: fallback,
    against: against,
    minimum: minimum,
  );
}

Color _ensureTokenContrastAcross({
  required Color preferred,
  required Color fallback,
  required List<Color> backgrounds,
  required double minimum,
}) {
  for (var percentage = 0; percentage <= 100; percentage += 1) {
    final candidate = Color.lerp(preferred, fallback, percentage / 100)!;
    if (backgrounds.every(
      (background) => _tokenContrast(candidate, background) >= minimum,
    )) {
      return candidate;
    }
  }
  return fallback;
}

double _tokenContrast(Color first, Color second) {
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
