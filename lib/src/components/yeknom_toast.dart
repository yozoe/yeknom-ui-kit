import 'dart:async';

import 'package:flutter/material.dart';

/// Overlay-based notifications shared by Yeknom applications.
abstract final class YeknomToast {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final List<_ToastEntry> _activeToasts = [];
  static OverlayEntry? _overlayEntry;

  static BuildContext? _globalContext;

  static Duration displayDuration = const Duration(seconds: 2);
  static double maxWidth = 480;
  static Color defaultBackgroundColor = Colors.black87;
  static Color successBackgroundColor = Colors.green.shade700;
  static Color errorBackgroundColor = Colors.red.shade700;
  static Color warningBackgroundColor = Colors.orange.shade700;
  static Color defaultTextColor = Colors.white;

  /// Registers a context below an [Overlay] when [navigatorKey] cannot be used.
  static void init(BuildContext context) {
    _globalContext = context;
  }

  static void show(String message, {Color? backgroundColor, Color? textColor}) {
    _showToast(
      message,
      backgroundColor ?? defaultBackgroundColor,
      textColor ?? defaultTextColor,
    );
  }

  static void showSuccess(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    _showToast(
      message,
      backgroundColor ?? successBackgroundColor,
      textColor ?? defaultTextColor,
    );
  }

  static void showError(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    _showToast(
      message,
      backgroundColor ?? errorBackgroundColor,
      textColor ?? defaultTextColor,
    );
  }

  static void showWarning(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    _showToast(
      message,
      backgroundColor ?? warningBackgroundColor,
      textColor ?? defaultTextColor,
    );
  }

  static void _showToast(
    String message,
    Color backgroundColor,
    Color textColor,
  ) {
    final overlayState =
        navigatorKey.currentState?.overlay ??
        (_globalContext == null
            ? null
            : Overlay.maybeOf(_globalContext!, rootOverlay: true));
    if (overlayState == null) return;

    final toastEntry = _ToastEntry(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
    _activeToasts.add(toastEntry);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => _ToastStack(
          entries: List.unmodifiable(_activeToasts),
          onDismissed: _removeToast,
        ),
      );
      overlayState.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  static void _removeToast(_ToastEntry entry) {
    if (!_activeToasts.remove(entry)) return;

    if (_activeToasts.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry?.markNeedsBuild();
    }
  }

  @visibleForTesting
  static void clear() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _activeToasts.clear();
    _globalContext = null;
  }
}

/// Compatibility API for applications migrating from `package:toast`.
///
/// New code should prefer [YeknomToast].
abstract final class Toast {
  static GlobalKey<NavigatorState> get navigatorKey => YeknomToast.navigatorKey;

  static Duration get displayDuration => YeknomToast.displayDuration;
  static set displayDuration(Duration value) {
    YeknomToast.displayDuration = value;
  }

  static double get maxWidth => YeknomToast.maxWidth;
  static set maxWidth(double value) {
    YeknomToast.maxWidth = value;
  }

  static Color get defaultBackgroundColor => YeknomToast.defaultBackgroundColor;
  static set defaultBackgroundColor(Color value) {
    YeknomToast.defaultBackgroundColor = value;
  }

  static Color get successBackgroundColor => YeknomToast.successBackgroundColor;
  static set successBackgroundColor(Color value) {
    YeknomToast.successBackgroundColor = value;
  }

  static Color get errorBackgroundColor => YeknomToast.errorBackgroundColor;
  static set errorBackgroundColor(Color value) {
    YeknomToast.errorBackgroundColor = value;
  }

  static Color get warningBackgroundColor => YeknomToast.warningBackgroundColor;
  static set warningBackgroundColor(Color value) {
    YeknomToast.warningBackgroundColor = value;
  }

  static Color get defaultTextColor => YeknomToast.defaultTextColor;
  static set defaultTextColor(Color value) {
    YeknomToast.defaultTextColor = value;
  }

  static void init(BuildContext context) {
    YeknomToast.init(context);
  }

  static void show(String message, {Color? backgroundColor, Color? textColor}) {
    YeknomToast.show(
      message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static void showSuccess(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    YeknomToast.showSuccess(
      message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static void showError(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    YeknomToast.showError(
      message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static void showWarning(
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    YeknomToast.showWarning(
      message,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  @visibleForTesting
  static void clear() {
    YeknomToast.clear();
  }
}

class _ToastEntry {
  _ToastEntry({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final Key key = UniqueKey();
  final String message;
  final Color backgroundColor;
  final Color textColor;
}

class _ToastStack extends StatelessWidget {
  const _ToastStack({required this.entries, required this.onDismissed});

  final List<_ToastEntry> entries;
  final ValueChanged<_ToastEntry> onDismissed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 60,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: YeknomToast.maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in entries)
                    _IndependentToastWidget(
                      key: entry.key,
                      message: entry.message,
                      backgroundColor: entry.backgroundColor,
                      textColor: entry.textColor,
                      onDismissed: () => onDismissed(entry),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndependentToastWidget extends StatefulWidget {
  const _IndependentToastWidget({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismissed,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onDismissed;

  @override
  State<_IndependentToastWidget> createState() =>
      _IndependentToastWidgetState();
}

class _IndependentToastWidgetState extends State<_IndependentToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(curve);

    _controller.forward();
    _dismissTimer = Timer(YeknomToast.displayDuration, _startDismiss);
  }

  Future<void> _startDismiss() async {
    if (_isDismissing) return;
    setState(() => _isDismissing = true);
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: _isDismissing ? _controller.value : 1,
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: widget.textColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
