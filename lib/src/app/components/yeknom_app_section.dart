import 'package:flutter/material.dart';

import '../foundation/yeknom_app_theme_tokens.dart';

/// A spacious content section for user-facing App pages.
class YeknomAppSection extends StatelessWidget {
  const YeknomAppSection({
    required this.title,
    required this.child,
    super.key,
    this.description,
    this.action,
  });

  final Widget title;
  final Widget child;
  final Widget? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = YeknomAppThemeTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaledTitle = MediaQuery.textScalerOf(context).scale(20);
        final stackAction =
            action != null && (constraints.maxWidth < 560 || scaledTitle >= 30);
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: DefaultTextStyle.merge(
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                child: title,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tokens.contentMaxWidth * 0.68,
                ),
                child: DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  child: description!,
                ),
              ),
            ],
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stackAction) ...[
              heading,
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: action!,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: heading),
                  if (action != null) ...[const SizedBox(width: 24), action!],
                ],
              ),
            const SizedBox(height: 24),
            child,
          ],
        );
      },
    );
  }
}
