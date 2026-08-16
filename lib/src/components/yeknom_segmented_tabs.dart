import 'package:flutter/material.dart';

class YeknomSegmentedTabs<T> extends StatelessWidget {
  const YeknomSegmentedTabs({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    super.key,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.selectedIcon,
    this.style,
    this.direction = Axis.horizontal,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final Widget? selectedIcon;
  final ButtonStyle? style;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
      selectedIcon: selectedIcon,
      style: style,
      direction: direction,
    );
  }
}
