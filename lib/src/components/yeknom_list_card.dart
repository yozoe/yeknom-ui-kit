import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

/// A compact, interactive list surface with Yeknom's workbench states.
class YeknomListCard extends StatefulWidget {
  const YeknomListCard({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.selectable = false,
    this.enabled = true,
    this.showChevron = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: YeknomSpacing.md,
      vertical: YeknomSpacing.md,
    ),
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;

  /// Whether this card participates in a selection set.
  ///
  /// A selected card is always exposed as selectable. Set this to true for an
  /// unselected card so assistive technology can announce its selection state.
  final bool selectable;
  final bool enabled;
  final bool showChevron;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<YeknomListCard> createState() => _YeknomListCardState();
}

class _YeknomListCardState extends State<YeknomListCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final interactive = widget.enabled && widget.onPressed != null;
    final exposesSelection = widget.selectable || widget.selected;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final accentuated = widget.selected || _focused;
    final background = widget.selected
        ? palette.selected
        : _hovered && interactive
        ? palette.raised
        : palette.module;
    final borderColor = accentuated ? palette.active : palette.border;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 140);

    final trailing =
        widget.trailing ??
        (widget.showChevron
            ? Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 19,
                color: widget.selected ? palette.active : palette.muted,
              )
            : null);

    return Semantics(
      container: true,
      explicitChildNodes: widget.semanticLabel != null,
      label: widget.semanticLabel,
      button: widget.onPressed != null,
      enabled: widget.onPressed == null ? null : widget.enabled,
      selected: exposesSelection ? widget.selected : null,
      onTap: interactive ? widget.onPressed : null,
      child: AnimatedOpacity(
        duration: duration,
        opacity: widget.enabled ? 1 : 0.48,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: background,
            borderRadius: YeknomRadii.medium,
            border: Border.all(color: borderColor, width: _focused ? 1.6 : 1),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: YeknomRadii.medium,
            clipBehavior: Clip.antiAlias,
            child: ExcludeFocus(
              excluding: !widget.enabled,
              child: IgnorePointer(
                ignoring: !widget.enabled,
                child: InkWell(
                  onTap: interactive ? widget.onPressed : null,
                  onHover: (value) {
                    if (_hovered != value) setState(() => _hovered = value);
                  },
                  onFocusChange: (value) {
                    if (_focused != value) setState(() => _focused = value);
                  },
                  focusNode: widget.focusNode,
                  autofocus: widget.autofocus,
                  canRequestFocus: interactive,
                  excludeFromSemantics: true,
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  child: Padding(
                    padding: widget.padding,
                    child: Row(
                      children: [
                        if (widget.leading != null) ...[
                          ExcludeSemantics(
                            excluding: widget.semanticLabel != null,
                            child: IconTheme.merge(
                              data: IconThemeData(
                                color: widget.selected
                                    ? palette.active
                                    : palette.muted,
                                size: 20,
                              ),
                              child: widget.leading!,
                            ),
                          ),
                          const SizedBox(width: YeknomSpacing.md),
                        ],
                        Expanded(
                          child: ExcludeSemantics(
                            excluding: widget.semanticLabel != null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DefaultTextStyle.merge(
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: widget.selected
                                            ? palette.active
                                            : palette.trace,
                                        fontSize: 13,
                                      ),
                                  child: widget.title,
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: YeknomSpacing.xs),
                                  DefaultTextStyle.merge(
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(height: 1.35),
                                    child: widget.subtitle!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: YeknomSpacing.md),
                          IconTheme.merge(
                            data: IconThemeData(color: palette.muted, size: 19),
                            child: trailing,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
