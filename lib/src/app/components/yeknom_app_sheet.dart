import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A keyboard-aware, scroll-safe bottom sheet for the App experience.
class YeknomAppSheet extends StatelessWidget {
  const YeknomAppSheet({
    required this.title,
    required this.child,
    super.key,
    this.actions = const [],
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.closeTooltip,
  });

  final Widget title;
  final Widget child;
  final List<Widget> actions;
  final bool showCloseButton;
  final bool showDragHandle;
  final String? closeTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sheetTheme = theme.bottomSheetTheme;
    final tokens = YeknomAppThemeTokens.of(context);
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion = mediaQuery.disableAnimations;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final availableHeight =
        mediaQuery.size.height - mediaQuery.padding.top - keyboardInset - 12;
    final themedConstraints =
        sheetTheme.constraints ?? const BoxConstraints(maxWidth: 640);
    final maxHeight = availableHeight
        .clamp(0.0, themedConstraints.maxHeight)
        .toDouble();
    final sheetConstraints = themedConstraints.copyWith(
      minHeight: themedConstraints.minHeight.clamp(0.0, maxHeight).toDouble(),
      maxHeight: maxHeight,
    );
    final hostedByBottomSheet =
        context.findAncestorWidgetOfExactType<BottomSheet>() != null;
    final sheetShape =
        sheetTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.modalRadius),
          ),
        );
    final dragHandleSize = sheetTheme.dragHandleSize ?? const Size(36, 4);

    return AnimatedPadding(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: sheetConstraints,
            child: Material(
              color: hostedByBottomSheet
                  ? Colors.transparent
                  : sheetTheme.modalBackgroundColor ??
                        sheetTheme.backgroundColor ??
                        tokens.surface,
              surfaceTintColor: hostedByBottomSheet
                  ? Colors.transparent
                  : sheetTheme.surfaceTintColor,
              shadowColor: sheetTheme.shadowColor,
              elevation: hostedByBottomSheet
                  ? 0
                  : sheetTheme.modalElevation ?? sheetTheme.elevation ?? 0,
              clipBehavior: sheetTheme.clipBehavior ?? Clip.antiAlias,
              shape: sheetShape,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDragHandle)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: ExcludeSemantics(
                            child: Container(
                              key: const ValueKey(
                                'yeknom_app_sheet_drag_handle',
                              ),
                              width: dragHandleSize.width,
                              height: dragHandleSize.height,
                              decoration: BoxDecoration(
                                color:
                                    sheetTheme.dragHandleColor ??
                                    colorScheme.outline,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        24,
                        showDragHandle ? 14 : 22,
                        16,
                        18,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Semantics(
                              container: true,
                              header: true,
                              namesRoute: true,
                              child: DefaultTextStyle.merge(
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                                child: title,
                              ),
                            ),
                          ),
                          if (showCloseButton) ...[
                            const SizedBox(width: 12),
                            SizedBox.square(
                              dimension: tokens.minimumTapTarget,
                              child: IconButton(
                                tooltip:
                                    closeTooltip ??
                                    MaterialLocalizations.of(
                                      context,
                                    ).closeButtonTooltip,
                                onPressed: () => Navigator.maybePop(context),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                      child: DefaultTextStyle.merge(
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        child: child,
                      ),
                    ),
                    if (actions.isNotEmpty)
                      ColoredBox(
                        color: tokens.surfaceSoft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: actions,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a [YeknomAppSheet] route without constraining its keyboard-aware body.
Future<T?> showYeknomAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    useSafeArea: false,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}
