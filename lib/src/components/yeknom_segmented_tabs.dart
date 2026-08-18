import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

/// A compact segmented control with a quiet track and filled selection.
class YeknomSegmentedTabs<T> extends StatefulWidget {
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
  State<YeknomSegmentedTabs<T>> createState() => _YeknomSegmentedTabsState<T>();
}

class _YeknomSegmentedTabsState<T> extends State<YeknomSegmentedTabs<T>> {
  bool _hasFocus = false;
  late FocusHighlightMode _highlightMode;

  @override
  void initState() {
    super.initState();
    _highlightMode = FocusManager.instance.highlightMode;
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChanged,
    );
    super.dispose();
  }

  void _handleHighlightModeChanged(FocusHighlightMode mode) {
    if (_highlightMode == mode) return;
    setState(() => _highlightMode = mode);
  }

  void _handleFocusChange(bool hasFocus) {
    if (_hasFocus == hasFocus) return;
    setState(() => _hasFocus = hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final ambientTheme = SegmentedButtonTheme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 150);
    final selectedFill = Color.alphaBlend(
      palette.active.withValues(alpha: palette.dark ? 0.26 : 0.22),
      palette.field,
    );
    final ambientTextStyle = ambientTheme.style?.textStyle;
    final selectedAwareTextStyle = WidgetStateProperty.resolveWith<TextStyle?>((
      states,
    ) {
      final inherited = ambientTextStyle?.resolve(states);
      final baseWeight = inherited?.fontWeight ?? FontWeight.w600;
      return (inherited ?? const TextStyle()).copyWith(
        fontSize: inherited?.fontSize ?? 12,
        fontWeight: states.contains(WidgetState.selected)
            ? baseWeight.value < FontWeight.w700.value
                  ? FontWeight.w700
                  : baseWeight
            : baseWeight,
        height: inherited?.height ?? 1.2,
      );
    });
    final brandedStyle = ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: selectedAwareTextStyle,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selectedFill;
        if (states.contains(WidgetState.hovered)) return palette.raised;
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return palette.faint;
        if (states.contains(WidgetState.selected)) return palette.trace;
        return palette.muted;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return palette.active.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return palette.active.withValues(alpha: 0.06);
        }
        return Colors.transparent;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return palette.faint;
        if (states.contains(WidgetState.selected)) return palette.trace;
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
      animationDuration: duration,
    );
    final effectiveThemeStyle =
        (ambientTheme.style?.merge(brandedStyle) ?? brandedStyle).copyWith(
          textStyle: selectedAwareTextStyle,
        );
    final segmentedButton = SegmentedButton<T>(
      segments: widget.segments,
      selected: widget.selected,
      onSelectionChanged: widget.onSelectionChanged,
      multiSelectionEnabled: widget.multiSelectionEnabled,
      emptySelectionAllowed: widget.emptySelectionAllowed,
      showSelectedIcon: widget.showSelectedIcon,
      selectedIcon: widget.selectedIcon,
      style: widget.style,
      direction: widget.direction,
    );
    final showFocusRing =
        _hasFocus && _highlightMode == FocusHighlightMode.traditional;
    final focusRingColor = _focusRingColor(palette);
    final track = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: YeknomRadii.control,
        border: Border.all(
          color: showFocusRing ? focusRingColor : Colors.transparent,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
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
    final focusAwareTrack = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: track,
    );
    if (widget.direction == Axis.vertical) return focusAwareTrack;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: focusAwareTrack,
    );
  }

  Color _focusRingColor(YeknomPalette palette) {
    final background = palette.field;
    final active = palette.active.withValues(alpha: 1);
    if (_contrast(active, background) >= 3) return active;

    final trace = palette.trace.withValues(alpha: 1);
    if (_contrast(trace, background) >= 3) return trace;

    return _contrast(Colors.black, background) >
            _contrast(Colors.white, background)
        ? Colors.black
        : Colors.white;
  }

  double _contrast(Color first, Color second) {
    final firstLuminance = first.computeLuminance();
    final secondLuminance = second.computeLuminance();
    final lighter = firstLuminance > secondLuminance
        ? firstLuminance
        : secondLuminance;
    final darker = firstLuminance > secondLuminance
        ? secondLuminance
        : firstLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
