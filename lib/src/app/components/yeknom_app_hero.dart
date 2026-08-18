import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A characteristic opening surface for an App page.
///
/// The visual direction uses a restrained dashboard panel, one compact signal
/// marker and an optional outlined shelf for product-specific content.
class YeknomAppHero extends StatelessWidget {
  const YeknomAppHero({
    required this.title,
    required this.description,
    super.key,
    this.eyebrow,
    this.actions = const [],
    this.visual,
    this.padding,
  });

  final Widget title;
  final Widget description;
  final Widget? eyebrow;
  final List<Widget> actions;
  final Widget? visual;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = YeknomAppThemeTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: compact ? 24 : 40,
              vertical: compact ? 24 : 32,
            );
        final copy = _HeroCopy(
          title: title,
          description: description,
          eyebrow: eyebrow,
          actions: actions,
          compact: compact,
        );
        final shelf = visual == null
            ? null
            : _VisualShelf(compact: compact, child: visual!);

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: resolvedPadding,
          decoration: BoxDecoration(
            color: tokens.heroBackground,
            borderRadius: BorderRadius.circular(tokens.heroRadius),
            border: Border.all(
              color: tokens.heroForeground.withValues(alpha: 0.14),
            ),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    copy,
                    if (shelf != null) ...[const SizedBox(height: 28), shelf],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: shelf == null ? 1 : 6, child: copy),
                    if (shelf != null) ...[
                      const SizedBox(width: 40),
                      Expanded(flex: 4, child: shelf),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.title,
    required this.description,
    required this.eyebrow,
    required this.actions,
    required this.compact,
  });

  final Widget title;
  final Widget description;
  final Widget? eyebrow;
  final List<Widget> actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = YeknomAppThemeTokens.of(context);
    final disabledFilledBackground = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.42),
      tokens.heroBackground,
    );
    final disabledContent = Color.alphaBlend(
      tokens.heroForeground.withValues(alpha: 0.48),
      tokens.heroBackground,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.heroAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const SizedBox.square(dimension: 7),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: DefaultTextStyle.merge(
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.heroMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                  child: eyebrow!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        Semantics(
          header: true,
          child: DefaultTextStyle.merge(
            style:
                (compact
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.headlineLarge)
                    ?.copyWith(
                      color: tokens.heroForeground,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                      letterSpacing: 0,
                    ),
            child: title,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodyLarge?.copyWith(
              color: tokens.heroMuted,
              height: 1.55,
            ),
            child: description,
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 28),
          Theme(
            data: theme.copyWith(
              filledButtonTheme: FilledButtonThemeData(
                style: (theme.filledButtonTheme.style ?? const ButtonStyle())
                    .copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledFilledBackground
                            : colorScheme.primary,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : colorScheme.onPrimary,
                      ),
                      iconColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : colorScheme.onPrimary,
                      ),
                    ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: (theme.outlinedButtonTheme.style ?? const ButtonStyle())
                    .copyWith(
                      backgroundColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : tokens.heroForeground,
                      ),
                      iconColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : tokens.heroForeground,
                      ),
                      side: WidgetStateProperty.resolveWith(
                        (states) => BorderSide(
                          color: tokens.heroForeground.withValues(
                            alpha: states.contains(WidgetState.disabled)
                                ? 0.16
                                : 0.34,
                          ),
                        ),
                      ),
                    ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: (theme.textButtonTheme.style ?? const ButtonStyle())
                    .copyWith(
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : tokens.heroForeground,
                      ),
                      iconColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.disabled)
                            ? disabledContent
                            : tokens.heroForeground,
                      ),
                    ),
              ),
            ),
            child: Wrap(spacing: 12, runSpacing: 12, children: actions),
          ),
        ],
      ],
    );
  }
}

class _VisualShelf extends StatelessWidget {
  const _VisualShelf({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = YeknomAppThemeTokens.of(context);
    final progressTrack = _progressTrackColor(tokens);
    final divider = BorderSide(
      color: tokens.heroForeground.withValues(alpha: 0.18),
    );

    return ProgressIndicatorTheme(
      data: ProgressIndicatorTheme.of(context).copyWith(
        color: tokens.heroForeground,
        linearTrackColor: progressTrack,
        circularTrackColor: progressTrack,
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 132 : 160),
        padding: compact
            ? const EdgeInsets.only(top: 24)
            : const EdgeInsetsDirectional.fromSTEB(28, 8, 0, 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: compact
              ? Border(top: divider)
              : BorderDirectional(start: divider),
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: tokens.heroForeground),
          child: DefaultTextStyle.merge(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.heroForeground),
            child: child,
          ),
        ),
      ),
    );
  }
}

Color _progressTrackColor(YeknomAppThemeTokens tokens) {
  final opaqueAction = Color.alphaBlend(
    tokens.heroAction,
    tokens.heroBackground,
  );
  for (var percentage = 16; percentage >= 0; percentage -= 1) {
    final candidate = Color.alphaBlend(
      tokens.heroForeground.withValues(alpha: percentage / 100),
      opaqueAction,
    );
    if (_contrast(candidate, tokens.heroForeground) >= 3) return candidate;
  }
  return opaqueAction;
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
