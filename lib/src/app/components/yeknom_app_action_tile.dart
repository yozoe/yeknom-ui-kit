import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A spacious App action row for settings, shortcuts and next-step actions.
class YeknomAppActionTile extends StatefulWidget {
  const YeknomAppActionTile({
    required this.title,
    required this.leading,
    super.key,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget title;
  final Widget leading;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<YeknomAppActionTile> createState() => _YeknomAppActionTileState();
}

class _YeknomAppActionTileState extends State<YeknomAppActionTile> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  void didUpdateWidget(covariant YeknomAppActionTile oldWidget) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = YeknomAppThemeTokens.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 140);
    final stateOpacity = _pressed
        ? 0.055
        : _hovered
        ? 0.025
        : _focused
        ? 0.018
        : 0.0;
    final backgroundColor = Color.alphaBlend(
      tokens.interactiveAccent.withValues(alpha: stateOpacity),
      tokens.surface,
    );
    final restingOutlineOpacity = colorScheme.brightness == Brightness.dark
        ? 0.46
        : 0.32;
    final outlineColor = _focused
        ? tokens.interactiveAccent
        : _pressed
        ? tokens.interactiveAccent.withValues(alpha: 0.38)
        : _hovered
        ? tokens.interactiveAccent.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: restingOutlineOpacity);

    final tile = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minHeight: tokens.minimumTapTarget),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(tokens.controlRadius),
        border: Border.all(color: outlineColor, width: _focused ? 2 : 1),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: tokens.interactiveAccent,
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.controlRadius),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scaledBody = MediaQuery.textScalerOf(context).scale(14);
                final stackTrailing =
                    widget.trailing != null &&
                    (constraints.maxWidth < 360 || scaledBody >= 22);
                final themedTrailing = widget.trailing == null
                    ? null
                    : IconTheme.merge(
                        data: IconThemeData(
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        child: widget.trailing!,
                      );
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.title,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 5),
                      DefaultTextStyle.merge(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        child: widget.subtitle!,
                      ),
                    ],
                    if (stackTrailing) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: themedTrailing!,
                      ),
                    ],
                  ],
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: tokens.minimumTapTarget,
                      height: tokens.minimumTapTarget,
                      child: Center(
                        child: IconTheme.merge(
                          data: IconThemeData(
                            color: tokens.interactiveAccent,
                            size: 22,
                          ),
                          child: widget.leading,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: copy),
                    if (widget.trailing != null && !stackTrailing) ...[
                      const SizedBox(width: 16),
                      themedTrailing!,
                    ],
                  ],
                );
              },
            ),
          ),
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
          child: IgnorePointer(ignoring: !widget.enabled, child: tile),
        ),
      ),
    );
  }
}
