import 'package:flutter/material.dart';

enum YeknomButtonVariant { filled, outlined, text }

class YeknomButton extends StatelessWidget {
  const YeknomButton({
    Widget? label,
    Widget? child,
    super.key,
    this.onPressed,
    this.icon,
    this.variant = YeknomButtonVariant.filled,
    this.loading = false,
    this.loadingSemanticsLabel,
    this.style,
    this.focusNode,
    this.autofocus = false,
  }) : assert((label == null) != (child == null)),
       label = label ?? child ?? const SizedBox.shrink();

  const YeknomButton.filled({
    Widget? label,
    Widget? child,
    Key? key,
    VoidCallback? onPressed,
    Widget? icon,
    bool loading = false,
    String? loadingSemanticsLabel,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
  }) : this(
         key: key,
         label: label,
         child: child,
         onPressed: onPressed,
         icon: icon,
         loading: loading,
         loadingSemanticsLabel: loadingSemanticsLabel,
         style: style,
         focusNode: focusNode,
         autofocus: autofocus,
       );

  const YeknomButton.outlined({
    Widget? label,
    Widget? child,
    Key? key,
    VoidCallback? onPressed,
    Widget? icon,
    bool loading = false,
    String? loadingSemanticsLabel,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
  }) : this(
         key: key,
         label: label,
         child: child,
         onPressed: onPressed,
         icon: icon,
         variant: YeknomButtonVariant.outlined,
         loading: loading,
         loadingSemanticsLabel: loadingSemanticsLabel,
         style: style,
         focusNode: focusNode,
         autofocus: autofocus,
       );

  const YeknomButton.text({
    Widget? label,
    Widget? child,
    Key? key,
    VoidCallback? onPressed,
    Widget? icon,
    bool loading = false,
    String? loadingSemanticsLabel,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
  }) : this(
         key: key,
         label: label,
         child: child,
         onPressed: onPressed,
         icon: icon,
         variant: YeknomButtonVariant.text,
         loading: loading,
         loadingSemanticsLabel: loadingSemanticsLabel,
         style: style,
         focusNode: focusNode,
         autofocus: autofocus,
       );

  final Widget label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final YeknomButtonVariant variant;
  final bool loading;
  final String? loadingSemanticsLabel;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final callback = loading ? null : onPressed;
    const progress = _YeknomButtonProgress();
    final effectiveLabel = loading && icon == null
        ? Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0, child: label),
              progress,
            ],
          )
        : label;
    final effectiveIcon = icon == null ? null : (loading ? progress : icon);

    final button = switch (variant) {
      YeknomButtonVariant.filled =>
        effectiveIcon == null
            ? FilledButton(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                child: effectiveLabel,
              )
            : FilledButton.icon(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                icon: effectiveIcon,
                label: effectiveLabel,
              ),
      YeknomButtonVariant.outlined =>
        effectiveIcon == null
            ? OutlinedButton(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                child: effectiveLabel,
              )
            : OutlinedButton.icon(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                icon: effectiveIcon,
                label: effectiveLabel,
              ),
      YeknomButtonVariant.text =>
        effectiveIcon == null
            ? TextButton(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                child: effectiveLabel,
              )
            : TextButton.icon(
                onPressed: callback,
                style: style,
                focusNode: focusNode,
                autofocus: autofocus,
                icon: effectiveIcon,
                label: effectiveLabel,
              ),
    };

    if (!loading || loadingSemanticsLabel == null) return button;
    return Semantics(
      label: loadingSemanticsLabel,
      button: true,
      enabled: false,
      excludeSemantics: true,
      child: button,
    );
  }
}

class _YeknomButtonProgress extends StatelessWidget {
  const _YeknomButtonProgress();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color:
            IconTheme.of(context).color ??
            DefaultTextStyle.of(context).style.color,
      ),
    );
  }
}

class YeknomIconButton extends StatelessWidget {
  const YeknomIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.tooltip,
    this.loading = false,
    this.loadingSemanticsLabel,
    this.style,
    this.iconSize,
    this.padding = const EdgeInsets.all(8),
    this.constraints,
    this.color,
    this.disabledColor,
    this.visualDensity,
    this.alignment = Alignment.center,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingSemanticsLabel;
  final ButtonStyle? style;
  final double? iconSize;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final Color? color;
  final Color? disabledColor;
  final VisualDensity? visualDensity;
  final AlignmentGeometry alignment;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: loading ? null : onPressed,
      tooltip: loading ? null : tooltip,
      style: style,
      iconSize: iconSize,
      padding: padding,
      constraints: constraints,
      color: color,
      disabledColor: disabledColor,
      visualDensity: visualDensity,
      alignment: alignment,
      focusNode: focusNode,
      autofocus: autofocus,
      icon: loading
          ? const SizedBox.square(
              dimension: 17,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon,
    );
    if (!loading || loadingSemanticsLabel == null) return button;
    return Semantics(
      label: loadingSemanticsLabel,
      button: true,
      enabled: false,
      excludeSemantics: true,
      child: button,
    );
  }
}
