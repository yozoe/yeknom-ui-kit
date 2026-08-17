import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

/// A compact segmented control with a quiet track and filled selection.
class YeknomSegmentedTabs<T> extends StatelessWidget {
  const YeknomSegmentedTabs({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    super.key,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = false,
    this.selectedIcon,
    this.style,
    this.direction = Axis.horizontal,
  }) : assert(segments.length > 0),
       assert(selected.length > 0 || emptySelectionAllowed),
       assert(selected.length < 2 || multiSelectionEnabled);

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
    final palette = YeknomPalette.of(context);
    final ambientTheme = SegmentedButtonTheme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final brandedStyle = ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return palette.selected;
        if (states.contains(WidgetState.hovered)) return palette.raised;
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return palette.faint;
        if (states.contains(WidgetState.selected)) return palette.active;
        return palette.muted;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return palette.active.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return palette.active.withValues(alpha: 0.06);
        }
        return Colors.transparent;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return palette.faint;
        if (states.contains(WidgetState.selected)) return palette.active;
        return palette.muted;
      }),
      iconSize: const WidgetStatePropertyAll(17),
      padding: const WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(
          horizontal: YeknomSpacing.md,
          vertical: YeknomSpacing.sm,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(48, 32)),
      side: const WidgetStatePropertyAll(BorderSide.none),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: YeknomRadii.control),
      ),
      animationDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 150),
    );
    final effectiveThemeStyle =
        ambientTheme.style?.merge(brandedStyle) ?? brandedStyle;
    final segmentedButton = SegmentedButton<T>(
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
    final track = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: YeknomRadii.control,
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: SegmentedButtonTheme(
          data: SegmentedButtonThemeData(
            style: effectiveThemeStyle,
            selectedIcon: ambientTheme.selectedIcon,
          ),
          child: segmentedButton,
        ),
      ),
    );
    if (direction == Axis.vertical) return track;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: track,
    );
  }
}
