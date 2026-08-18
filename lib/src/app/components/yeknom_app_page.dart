import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A centered, scrollable page shell for Yeknom's user-facing App experience.
///
/// The supplied [controller] remains owned by the caller.
class YeknomAppPage extends StatelessWidget {
  const YeknomAppPage({
    required this.child,
    super.key,
    this.padding,
    this.maxWidth,
    this.controller,
    this.physics,
    this.safeArea = true,
  }) : assert(maxWidth == null || maxWidth > 0);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final tokens = YeknomAppThemeTokens.of(context);
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: constraints.maxWidth < 600
                  ? 16
                  : constraints.maxWidth < 1024
                  ? tokens.pageGutter
                  : tokens.pageGutter + 12,
              vertical: constraints.maxWidth < 600 ? 20 : 32,
            );

        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: resolvedPadding,
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? tokens.contentMaxWidth,
              ),
              child: child,
            ),
          ),
        );
      },
    );

    return ColoredBox(
      color: tokens.canvas,
      child: safeArea ? SafeArea(child: content) : content,
    );
  }
}
