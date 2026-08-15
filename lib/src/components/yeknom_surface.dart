import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

class YeknomSurface extends StatelessWidget {
  const YeknomSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(YeknomSpacing.lg),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = YeknomRadii.large,
    this.constraints,
    this.width,
    this.height,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry borderRadius;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.module,
        border: Border.all(color: borderColor ?? palette.border),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
