import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

/// A compact workbench switch with a semantic-color status thumb.
class YeknomSwitch extends StatefulWidget {
  const YeknomSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final MaterialTapTargetSize? materialTapTargetSize;

  @override
  State<YeknomSwitch> createState() => _YeknomSwitchState();
}

class _YeknomSwitchState extends State<YeknomSwitch> {
  static const _trackWidth = 42.0;
  static const _trackHeight = 22.0;
  static const _restingThumbSize = 16.0;
  static const _pressedThumbSize = 18.0;
  static const _thumbTravel =
      _trackWidth - (YeknomSpacing.xxs * 2) - _pressedThumbSize;

  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  double? _dragPosition;

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    if (_enabled) widget.onChanged?.call(!widget.value);
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    if (_dragPosition == null) setState(() => _pressed = false);
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _pressed = true;
      _dragPosition = widget.value ? 1 : 0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final delta = (details.primaryDelta ?? 0) * direction / _thumbTravel;
    setState(() {
      _dragPosition = ((_dragPosition ?? (widget.value ? 1 : 0)) + delta).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final nextValue = (_dragPosition ?? (widget.value ? 1 : 0)) >= 0.5;
    if (nextValue != widget.value) widget.onChanged?.call(nextValue);
    if (!mounted) return;
    setState(() {
      _pressed = false;
      _dragPosition = null;
    });
  }

  void _handleDragCancel() {
    setState(() {
      _pressed = false;
      _dragPosition = null;
    });
  }

  @override
  void didUpdateWidget(covariant YeknomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onChanged != null && widget.onChanged == null) {
      _pressed = false;
      _dragPosition = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final tapTarget =
        widget.materialTapTargetSize ??
        SwitchTheme.of(context).materialTapTargetSize ??
        Theme.of(context).materialTapTargetSize;
    final shrinkWrap = tapTarget == MaterialTapTargetSize.shrinkWrap;
    final thumbSize = _pressed ? _pressedThumbSize : _restingThumbSize;
    final position = _dragPosition ?? (widget.value ? 1.0 : 0.0);
    final trackColor = widget.value
        ? palette.selected
        : _hovered && _enabled
        ? palette.raised
        : palette.field;
    final trackBorder = _focused
        ? palette.active
        : _hovered && _enabled
        ? palette.controlBorder
        : palette.border;
    final thumbColor = !_enabled
        ? palette.faint
        : widget.value
        ? palette.active
        : palette.muted;

    final track = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      width: _trackWidth,
      height: _trackHeight,
      padding: const EdgeInsets.all(YeknomSpacing.xxs),
      decoration: BoxDecoration(
        color: trackColor,
        border: Border.all(color: trackBorder, width: _focused ? 1.5 : 1),
        borderRadius: YeknomRadii.pill,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: palette.active.withValues(alpha: 0.18),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: _dragPosition == null ? duration : Duration.zero,
        curve: Curves.easeOutCubic,
        alignment: AlignmentDirectional((position * 2) - 1, 0),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          width: thumbSize,
          height: thumbSize,
          decoration: BoxDecoration(color: thumbColor, shape: BoxShape.circle),
        ),
      ),
    );

    final control = FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: _enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _toggle();
            return null;
          },
        ),
      },
      onShowHoverHighlight: (value) {
        if (_hovered != value) setState(() => _hovered = value);
      },
      onShowFocusHighlight: (value) {
        if (_focused != value) setState(() => _focused = value);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        dragStartBehavior: DragStartBehavior.down,
        onTap: _enabled ? _toggle : null,
        onTapDown: _enabled ? _handleTapDown : null,
        onTapUp: _enabled ? _handleTapUp : null,
        onTapCancel: _enabled ? _handleTapCancel : null,
        onHorizontalDragStart: _enabled ? _handleDragStart : null,
        onHorizontalDragUpdate: _enabled ? _handleDragUpdate : null,
        onHorizontalDragEnd: _enabled ? _handleDragEnd : null,
        onHorizontalDragCancel: _enabled ? _handleDragCancel : null,
        child: SizedBox(
          width: shrinkWrap ? _trackWidth : 48,
          height: shrinkWrap ? _trackHeight : 48,
          child: Center(child: track),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      toggled: widget.value,
      enabled: _enabled,
      onTap: _enabled ? _toggle : null,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: duration,
        opacity: _enabled ? 1 : 0.45,
        child: control,
      ),
    );
  }
}

class YeknomSwitchTile extends StatelessWidget {
  const YeknomSwitchTile({
    required this.value,
    required this.onChanged,
    required this.title,
    super.key,
    this.subtitle,
    this.secondary,
    this.contentPadding,
    this.dense,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final EdgeInsetsGeometry? contentPadding;
  final bool? dense;
  final ListTileControlAffinity controlAffinity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final leadingControl = controlAffinity == ListTileControlAffinity.leading;
    final control = ExcludeFocus(
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: YeknomSwitch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
    final tile = InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      excludeFromSemantics: true,
      borderRadius: YeknomRadii.control,
      child: ListTile(
        enabled: enabled,
        title: title,
        subtitle: subtitle,
        leading: leadingControl ? control : secondary,
        trailing: leadingControl ? secondary : control,
        contentPadding: contentPadding,
        dense: dense,
      ),
    );

    return MergeSemantics(
      child: Semantics(
        container: true,
        label: semanticLabel,
        toggled: value,
        enabled: enabled,
        onTap: enabled ? () => onChanged?.call(!value) : null,
        excludeSemantics: semanticLabel != null,
        child: tile,
      ),
    );
  }
}
