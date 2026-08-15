import 'package:flutter/material.dart';

import 'yeknom_palette.dart';

enum YeknomTone { neutral, accent, info, success, warning, danger }

extension YeknomToneColor on YeknomTone {
  Color resolve(YeknomPalette palette) {
    return switch (this) {
      YeknomTone.neutral => palette.muted,
      YeknomTone.accent => palette.signal,
      YeknomTone.info => palette.active,
      YeknomTone.success => palette.ack,
      YeknomTone.warning => palette.warning,
      YeknomTone.danger => palette.fault,
    };
  }
}
