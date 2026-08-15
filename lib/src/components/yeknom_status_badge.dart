import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tone.dart';

class YeknomStatusBadge extends StatelessWidget {
  const YeknomStatusBadge({
    required this.label,
    super.key,
    this.tone = YeknomTone.neutral,
    this.color,
    this.leading,
    this.semanticsLabel,
    this.liveRegion = false,
  });

  final String label;
  final YeknomTone tone;
  final Color? color;
  final Widget? leading;
  final String? semanticsLabel;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final resolvedColor = color ?? tone.resolve(palette);
    return Semantics(
      liveRegion: liveRegion,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: resolvedColor.withValues(alpha: 0.09),
          border: Border.all(color: resolvedColor.withValues(alpha: 0.32)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading ??
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: resolvedColor,
                    shape: BoxShape.circle,
                  ),
                ),
            const SizedBox(width: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.trace,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
