import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A lightly outlined App surface with restrained elevation and complete input
/// states.
class YeknomAppCard extends StatefulWidget {
  const YeknomAppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(24),
    this.onPressed,
    this.semanticLabel,
    this.enabled = true,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool enabled;
  final Color? color;

  @override
  State<YeknomAppCard> createState() => _YeknomAppCardState();
}

class _YeknomAppCardState extends State<YeknomAppCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  void didUpdateWidget(covariant YeknomAppCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasInteractive = oldWidget.enabled && oldWidget.onPressed != null;
    if (wasInteractive && !_interactive) {
      _hovered = false;
      _focused = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = YeknomAppThemeTokens.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 150);
    final baseColor = widget.color ?? tokens.surface;
    final stateOpacity = _pressed
        ? 0.055
        : _hovered
        ? 0.025
        : _focused
        ? 0.018
        : 0.0;
    final backgroundColor = Color.alphaBlend(
      tokens.interactiveAccent.withValues(alpha: stateOpacity),
      baseColor,
    );
    final restingOutlineOpacity = colorScheme.brightness == Brightness.dark
        ? 0.48
        : 0.34;
    final outlineColor = _focused
        ? tokens.interactiveAccent
        : _pressed
        ? tokens.interactiveAccent.withValues(alpha: 0.42)
        : _hovered
        ? tokens.interactiveAccent.withValues(alpha: 0.28)
        : colorScheme.outlineVariant.withValues(alpha: restingOutlineOpacity);
    final shadows = <BoxShadow>[
      BoxShadow(
        color: tokens.shadowColor.withValues(
          alpha: (tokens.shadowColor.a * (_hovered ? 0.72 : 0.5))
              .clamp(0.0, 1.0)
              .toDouble(),
        ),
        blurRadius: _hovered ? 12 : 8,
        offset: Offset(0, _hovered ? 4 : 2),
      ),
    ];

    final card = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      constraints: _interactive
          ? BoxConstraints(
              minWidth: tokens.minimumTapTarget,
              minHeight: tokens.minimumTapTarget,
            )
          : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: outlineColor, width: _focused ? 2 : 1),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _interactive ? widget.onPressed : null,
          onHover: _interactive
              ? (value) {
                  if (_hovered != value) setState(() => _hovered = value);
                }
              : null,
          onFocusChange: _interactive
              ? (value) {
                  if (_focused != value) setState(() => _focused = value);
                }
              : null,
          onHighlightChanged: _interactive
              ? (value) {
                  if (_pressed != value) setState(() => _pressed = value);
                }
              : null,
          canRequestFocus: _interactive,
          excludeFromSemantics: true,
          overlayColor: WidgetStatePropertyAll(
            tokens.interactiveAccent.withValues(alpha: 0.07),
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      button: widget.onPressed != null,
      enabled: widget.onPressed == null ? null : widget.enabled,
      onTap: _interactive ? widget.onPressed : null,
      excludeSemantics: widget.semanticLabel != null,
      child: AnimatedOpacity(
        duration: duration,
        opacity: widget.enabled ? 1 : 0.46,
        child: ExcludeFocus(
          excluding: !widget.enabled,
          child: IgnorePointer(ignoring: !widget.enabled, child: card),
        ),
      ),
    );
  }
}
