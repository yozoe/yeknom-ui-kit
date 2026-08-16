import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog_section.dart';

class CatalogPageHeader extends StatelessWidget {
  const CatalogPageHeader({required this.section, super.key});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: YeknomSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.eyebrow,
            style: TextStyle(
              color: palette.signal,
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: YeknomSpacing.sm),
          Text(
            section.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: YeknomSpacing.sm),
          Text(
            section.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class CatalogPanel extends StatelessWidget {
  const CatalogPanel({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
    this.description,
    this.trailing,
    this.padding = const EdgeInsets.all(YeknomSpacing.lg),
  });

  final String title;
  final IconData icon;
  final String? description;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return YeknomSurface(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackTrailing = trailing != null && constraints.maxWidth < 440;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              YeknomSectionHeader(
                icon: icon,
                title: title,
                description: description,
                trailing: stackTrailing ? null : trailing,
              ),
              if (stackTrailing) ...[
                const SizedBox(height: YeknomSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: trailing!,
                ),
              ],
              const SizedBox(height: YeknomSpacing.lg),
              child,
            ],
          );
        },
      ),
    );
  }
}

class CatalogGrid extends StatelessWidget {
  const CatalogGrid({
    required this.children,
    super.key,
    this.breakpoint = 760,
    this.gap = YeknomSpacing.lg,
  });

  final List<Widget> children;
  final double breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= breakpoint ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class CatalogCode extends StatelessWidget {
  const CatalogCode(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: palette.field,
        border: Border.all(color: palette.border),
        borderRadius: YeknomRadii.compact,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: palette.muted,
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CatalogMetric extends StatelessWidget {
  const CatalogMetric({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: palette.trace,
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: palette.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String colorHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String colorTokenValue(Color color) {
  final argb = color.toARGB32();
  final alpha = (argb >> 24) & 0xFF;
  if (alpha == 0xFF) return colorHex(color);
  final opacity = (alpha / 0xFF * 100).round();
  return '${colorHex(color)} · $opacity%';
}
