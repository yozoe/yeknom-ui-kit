import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tone.dart';
import 'yeknom_icon_frame.dart';
import 'yeknom_surface.dart';

class YeknomStateView extends StatelessWidget {
  const YeknomStateView({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.tone = YeknomTone.neutral,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.panelled = false,
    this.selectableMessage = false,
    this.maxWidth = 440,
  }) : assert(
         (actionLabel == null && onAction == null) ||
             (actionLabel != null && onAction != null),
       );

  const YeknomStateView.error({
    required String title,
    Key? key,
    String? message,
    String? actionLabel,
    IconData actionIcon = Icons.refresh_rounded,
    VoidCallback? onAction,
    bool panelled = true,
    bool selectableMessage = true,
    double maxWidth = 440,
  }) : this(
         key: key,
         title: title,
         message: message,
         icon: Icons.error_outline_rounded,
         tone: YeknomTone.danger,
         actionLabel: actionLabel,
         actionIcon: actionIcon,
         onAction: onAction,
         panelled: panelled,
         selectableMessage: selectableMessage,
         maxWidth: maxWidth,
       );

  const YeknomStateView.empty({
    required String title,
    Key? key,
    String? message,
    IconData icon = Icons.inbox_outlined,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
    bool panelled = false,
    double maxWidth = 440,
  }) : this(
         key: key,
         title: title,
         message: message,
         icon: icon,
         actionLabel: actionLabel,
         actionIcon: actionIcon,
         onAction: onAction,
         panelled: panelled,
         maxWidth: maxWidth,
       );

  final String title;
  final String? message;
  final IconData icon;
  final YeknomTone tone;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool panelled;
  final bool selectableMessage;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final color = tone.resolve(palette);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        YeknomIconFrame(
          icon: icon,
          color: color,
          backgroundColor: tone == YeknomTone.neutral
              ? palette.field
              : color.withValues(alpha: 0.12),
          borderColor: tone == YeknomTone.neutral ? palette.border : null,
          size: 46,
          iconSize: 25,
        ),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        if (message case final message?) ...[
          const SizedBox(height: 7),
          if (selectableMessage)
            SelectableText(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tone == YeknomTone.danger ? color : palette.muted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tone == YeknomTone.danger ? color : palette.muted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
        ],
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 18),
          if (actionIcon == null)
            FilledButton(onPressed: onAction, child: Text(actionLabel!))
          else
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 17),
              label: Text(actionLabel!),
            ),
        ],
      ],
    );
    final body = panelled
        ? YeknomSurface(
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(14),
            child: content,
          )
        : content;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: body,
        ),
      ),
    );
  }
}
