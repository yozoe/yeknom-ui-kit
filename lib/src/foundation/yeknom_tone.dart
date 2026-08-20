import 'package:flutter/material.dart';

import 'yeknom_palette.dart';

enum YeknomTone { neutral, accent, info, success, warning, danger }

extension YeknomToneColor on YeknomTone {
  Color resolve(YeknomPalette palette) {
    return switch (this) {
      // Neutral status indicators use a dedicated opaque grey. Reusing a
      // transparent text or border token loses graphical contrast in badges.
      YeknomTone.neutral =>
        palette.dark ? const Color(0xFF6E777A) : const Color(0xFF657074),
      YeknomTone.accent => palette.signal,
      YeknomTone.info => palette.active,
      YeknomTone.success => palette.ack,
      YeknomTone.warning => palette.warning,
      YeknomTone.danger => palette.fault,
    };
  }
}
