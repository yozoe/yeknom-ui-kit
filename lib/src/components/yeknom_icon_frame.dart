import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

class YeknomIconFrame extends StatelessWidget {
  const YeknomIconFrame({
    required this.icon,
    super.key,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = YeknomRadii.medium,
    this.semanticLabel,
  });

  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final BorderRadiusGeometry borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final foreground = color ?? palette.active;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? foreground.withValues(alpha: 0.11),
        borderRadius: borderRadius,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: foreground,
        size: iconSize,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
