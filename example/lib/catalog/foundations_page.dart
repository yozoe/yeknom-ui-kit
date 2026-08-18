import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_workbench.dart';

import 'catalog_section.dart';
import 'catalog_widgets.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogPageHeader(section: CatalogSection.foundations),
        const _PalettePanel(),
        const SizedBox(height: YeknomSpacing.lg),
        CatalogGrid(
          children: const [
            CatalogPanel(
              title: '间距比例',
              description: '从 2 到 32 的紧凑桌面节奏。',
              icon: Icons.space_bar_rounded,
              child: _SpacingScale(),
            ),
            CatalogPanel(
              title: '圆角层级',
              description: '控件克制，容器更柔和，胶囊只用于状态。',
              icon: Icons.rounded_corner_rounded,
              child: _RadiusScale(),
            ),
            CatalogPanel(
              title: '文字层级',
              description: '系统字体用于阅读，等宽字体用于数据与 token。',
              icon: Icons.text_fields_rounded,
              child: _TypeScale(),
            ),
            CatalogPanel(
              title: '语义原则',
              description: '颜色描述界面职责，不绑定具体业务。',
              icon: Icons.schema_outlined,
              child: _SemanticRules(),
            ),
          ],
        ),
      ],
    );
  }
}

class _PalettePanel extends StatelessWidget {
  const _PalettePanel();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final tokens = [
      ('bench', palette.bench),
      ('module', palette.module),
      ('trace', palette.trace),
      ('signal', palette.signal),
      ('active', palette.active),
      ('ack', palette.ack),
      ('warning', palette.warning),
      ('fault', palette.fault),
      ('onSignal', palette.onSignal),
      ('muted', palette.muted),
      ('faint', palette.faint),
      ('border', palette.border),
      ('controlBorder', palette.controlBorder),
      ('field', palette.field),
      ('raised', palette.raised),
      ('selected', palette.selected),
      ('signalSelected', palette.signalSelected),
    ];
    return CatalogPanel(
      title: '语义色板',
      description: palette.dark
          ? '当前解析为 Dark palette。'
          : '当前解析为 Light palette。',
      icon: Icons.palette_outlined,
      trailing: CatalogCode(
        palette.dark ? 'Brightness.dark' : 'Brightness.light',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 940
              ? 4
              : constraints.maxWidth >= 620
              ? 3
              : constraints.maxWidth >= 390
              ? 2
              : 1;
          const gap = YeknomSpacing.sm;
          final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final token in tokens)
                SizedBox(
                  width: width,
                  child: _ColorToken(name: token.$1, color: token.$2),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorToken extends StatelessWidget {
  const _ColorToken({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(YeknomSpacing.sm),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: YeknomRadii.control,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: YeknomRadii.compact,
              border: Border.all(color: palette.border),
            ),
          ),
          const SizedBox(width: YeknomSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.trace,
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  colorTokenValue(color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.muted,
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final values = [
      ('xxs', YeknomSpacing.xxs),
      ('xs', YeknomSpacing.xs),
      ('sm', YeknomSpacing.sm),
      ('md', YeknomSpacing.md),
      ('lg', YeknomSpacing.lg),
      ('xl', YeknomSpacing.xl),
      ('xxl', YeknomSpacing.xxl),
    ];
    return Column(
      children: [
        for (final value in values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    value.$1,
                    style: TextStyle(
                      color: palette.muted,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: value.$2 * 4,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.active,
                          borderRadius: YeknomRadii.pill,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: YeknomSpacing.sm),
                Text(
                  '${value.$2.toInt()} px',
                  style: TextStyle(
                    color: palette.trace,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RadiusScale extends StatelessWidget {
  const _RadiusScale();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final values = [
      ('compact', YeknomRadii.compact, '8'),
      ('control', YeknomRadii.control, '9'),
      ('medium', YeknomRadii.medium, '12'),
      ('large', YeknomRadii.large, '16'),
      ('pill', YeknomRadii.pill, '999'),
    ];
    return Wrap(
      spacing: YeknomSpacing.md,
      runSpacing: YeknomSpacing.md,
      children: [
        for (final value in values)
          SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 48,
                  decoration: BoxDecoration(
                    color: palette.selected,
                    borderRadius: value.$2,
                    border: Border.all(color: palette.active),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value.$1,
                  style: TextStyle(
                    color: palette.trace,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${value.$3} px',
                  style: TextStyle(
                    color: palette.muted,
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('工作台标题', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: YeknomSpacing.md),
        Text('模块标题', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: YeknomSpacing.sm),
        Text(
          '正文用于说明当前状态和下一步操作。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: YeknomSpacing.sm),
        Text('次要信息保持克制，但仍应清晰可读。', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: YeknomSpacing.md),
        Text(
          'release/1.4.0 · BUILD #482',
          style: TextStyle(
            color: palette.signal,
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _SemanticRules extends StatelessWidget {
  const _SemanticRules();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final rules = [
      (palette.signal, 'Signal', '需要注意或作为模块强调色'),
      (palette.active, 'Active', '当前选择、链接和进行中状态'),
      (palette.ack, 'Ack', '成功、就绪和已确认状态'),
      (palette.fault, 'Fault', '失败、危险和不可恢复状态'),
    ];
    return Column(
      children: [
        for (final rule in rules)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 28,
                  decoration: BoxDecoration(
                    color: rule.$1,
                    borderRadius: YeknomRadii.pill,
                  ),
                ),
                const SizedBox(width: YeknomSpacing.sm),
                SizedBox(
                  width: 58,
                  child: Text(
                    rule.$2,
                    style: TextStyle(
                      color: palette.trace,
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rule.$3,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
