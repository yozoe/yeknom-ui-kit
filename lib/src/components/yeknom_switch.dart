import 'package:flutter/material.dart';

class YeknomSwitch extends StatelessWidget {
  const YeknomSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final control = Switch(
      value: value,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
    );
    if (semanticLabel == null) return control;
    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: onChanged != null,
      excludeSemantics: true,
      child: control,
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
    final tile = SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      contentPadding: contentPadding,
      dense: dense,
      controlAffinity: controlAffinity,
    );
    if (semanticLabel == null) return tile;
    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: onChanged != null,
      excludeSemantics: true,
      child: tile,
    );
  }
}
