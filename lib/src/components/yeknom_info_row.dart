import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';

class YeknomInfoRow extends StatelessWidget {
  const YeknomInfoRow({
    required this.label,
    required this.value,
    super.key,
    this.labelWidth = 90,
    this.selectable = true,
    this.semanticLabel,
  });

  final String label;
  final String value;
  final double labelWidth;
  final bool selectable;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final valueStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: ExcludeSemantics(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.muted),
            ),
          ),
        ),
        Expanded(
          child: selectable
              ? SelectableText(
                  value,
                  style: valueStyle,
                  semanticsLabel: semanticLabel ?? '$label: $value',
                )
              : Text(
                  value,
                  style: valueStyle,
                  semanticsLabel: semanticLabel ?? '$label: $value',
                ),
        ),
      ],
    );
  }
}
