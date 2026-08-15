import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';

class YeknomSectionHeader extends StatelessWidget {
  const YeknomSectionHeader({
    required this.title,
    super.key,
    this.icon,
    this.leading,
    this.description,
    this.trailing,
    this.accentColor,
  }) : assert(icon == null || leading == null);

  final String title;
  final IconData? icon;
  final Widget? leading;
  final String? description;
  final Widget? trailing;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final resolvedLeading =
        leading ??
        (icon == null
            ? null
            : Icon(icon, size: 18, color: accentColor ?? palette.signal));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resolvedLeading != null) ...[
          resolvedLeading,
          const SizedBox(width: 9),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.trace,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (description case final description?) ...[
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
