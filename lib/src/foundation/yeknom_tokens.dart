import 'package:flutter/widgets.dart';

abstract final class YeknomSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class YeknomRadii {
  static const compact = BorderRadius.all(Radius.circular(8));
  static const control = BorderRadius.all(Radius.circular(9));
  static const medium = BorderRadius.all(Radius.circular(12));
  static const large = BorderRadius.all(Radius.circular(16));
  static const pill = BorderRadius.all(Radius.circular(999));
}
