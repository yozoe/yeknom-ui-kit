import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';
import 'yeknom_button.dart';

enum YeknomDialogVariant { standard, danger }

enum YeknomDialogActionVariant { primary, secondary, danger }

/// An action with the same hierarchy and danger treatment as [YeknomDialog].
class YeknomDialogAction extends StatelessWidget {
  const YeknomDialogAction({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = YeknomDialogActionVariant.primary,
    this.icon,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final YeknomDialogActionVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return switch (variant) {
      YeknomDialogActionVariant.primary => YeknomButton.filled(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
      YeknomDialogActionVariant.secondary => YeknomButton.outlined(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
      YeknomDialogActionVariant.danger => YeknomButton.filled(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: FilledButton.styleFrom(
          backgroundColor: palette.fault,
          foregroundColor:
              ThemeData.estimateBrightnessForColor(palette.fault) ==
                  Brightness.dark
              ? Colors.white
              : const Color(0xFF32120D),
        ),
      ),
    };
  }
}

/// A responsive dialog shell with structured header, content and action regions.
class YeknomDialog extends StatelessWidget {
  const YeknomDialog({
    required this.title,
    required this.content,
    super.key,
    this.actions = const [],
    this.icon,
    this.variant = YeknomDialogVariant.standard,
    this.onClose,
    this.closeTooltip,
    this.maxWidth = 520,
    this.insetPadding = const EdgeInsets.all(YeknomSpacing.xl),
    this.contentPadding = const EdgeInsets.all(YeknomSpacing.lg),
  });

  const YeknomDialog.danger({
    required Widget title,
    required Widget content,
    Key? key,
    List<Widget> actions = const [],
    IconData? icon = Icons.warning_amber_rounded,
    VoidCallback? onClose,
    String? closeTooltip,
    double maxWidth = 520,
    EdgeInsets insetPadding = const EdgeInsets.all(YeknomSpacing.xl),
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(YeknomSpacing.lg),
  }) : this(
         key: key,
         title: title,
         content: content,
         actions: actions,
         icon: icon,
         variant: YeknomDialogVariant.danger,
         onClose: onClose,
         closeTooltip: closeTooltip,
         maxWidth: maxWidth,
         insetPadding: insetPadding,
         contentPadding: contentPadding,
       );

  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;
  final YeknomDialogVariant variant;
  final VoidCallback? onClose;
  final String? closeTooltip;
  final double maxWidth;
  final EdgeInsets insetPadding;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final accent = variant == YeknomDialogVariant.danger
        ? palette.fault
        : palette.active;
    final availableHeight =
        MediaQuery.sizeOf(context).height - insetPadding.vertical;

    return Dialog(
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: availableHeight.clamp(0, double.infinity).toDouble(),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(child: Container(height: 3, color: accent)),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  YeknomSpacing.lg,
                  YeknomSpacing.md,
                  YeknomSpacing.md,
                  YeknomSpacing.md,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.11),
                          borderRadius: YeknomRadii.control,
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, color: accent, size: 19),
                      ),
                      const SizedBox(width: YeknomSpacing.md),
                    ],
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: DefaultTextStyle.merge(
                          style: Theme.of(context).dialogTheme.titleTextStyle,
                          child: title,
                        ),
                      ),
                    ),
                    if (onClose != null) ...[
                      const SizedBox(width: YeknomSpacing.sm),
                      YeknomIconButton(
                        onPressed: onClose,
                        tooltip:
                            closeTooltip ??
                            MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(color: palette.border),
              Padding(
                padding: contentPadding,
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).dialogTheme.contentTextStyle,
                  child: content,
                ),
              ),
              if (actions.isNotEmpty) ...[
                Divider(color: palette.border),
                Container(
                  color: palette.field,
                  padding: const EdgeInsets.all(YeknomSpacing.md),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: YeknomSpacing.sm,
                    runSpacing: YeknomSpacing.sm,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
