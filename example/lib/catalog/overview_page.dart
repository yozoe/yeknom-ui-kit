import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog_section.dart';
import 'catalog_widgets.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogPageHeader(section: CatalogSection.overview),
        const _OverviewHero(),
        const SizedBox(height: YeknomSpacing.lg),
        const _SemanticSignalStrip(),
        const SizedBox(height: YeknomSpacing.lg),
        CatalogGrid(
          children: const [
            CatalogPanel(
              title: '交互基线',
              description: '按钮、输入与分段选择直接继承主题。',
              icon: Icons.tune_rounded,
              child: _ControlsSample(),
            ),
            CatalogPanel(
              title: '运行状态',
              description: '同一套语义色覆盖信息、成功、警告与失败。',
              icon: Icons.monitor_heart_outlined,
              child: _SystemStatusSample(),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return YeknomSurface(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final introduction = Padding(
            padding: EdgeInsets.all(compact ? 22 : 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const YeknomIconFrame(
                      icon: Icons.view_quilt_outlined,
                      size: 38,
                      iconSize: 19,
                    ),
                    const SizedBox(width: YeknomSpacing.md),
                    Expanded(
                      child: Text(
                        'YEKNOM / VISUAL SYSTEM',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.signal,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: YeknomSpacing.xl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    '把工作台视觉，\n变成可复用的系统',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: compact ? 28 : 38,
                      height: 1.12,
                      letterSpacing: -1.1,
                    ),
                  ),
                ),
                const SizedBox(height: YeknomSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 570),
                  child: Text(
                    '这个 Catalog 用真实控件检查主题、状态与响应式边界。切换主题时，所有示例会同步更新。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.muted,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: YeknomSpacing.xl),
                const Wrap(
                  spacing: 28,
                  runSpacing: 14,
                  children: [
                    CatalogMetric(value: '17', label: 'semantic tokens'),
                    CatalogMetric(value: '15', label: 'display components'),
                    CatalogMetric(value: '02', label: 'theme modes'),
                  ],
                ),
              ],
            ),
          );
          final trace = Container(
            width: compact ? double.infinity : 250,
            padding: compact
                ? const EdgeInsets.all(YeknomSpacing.lg)
                : const EdgeInsets.symmetric(
                    horizontal: YeknomSpacing.lg,
                    vertical: YeknomSpacing.xxl,
                  ),
            decoration: BoxDecoration(
              color: palette.raised,
              border: Border(
                left: compact
                    ? BorderSide.none
                    : BorderSide(color: palette.border),
                top: compact
                    ? BorderSide(color: palette.border)
                    : BorderSide.none,
              ),
            ),
            child: const _ThemeTrace(),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [introduction, trace],
            );
          }
          return Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: FixedColumnWidth(250),
            },
            children: [
              TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: introduction,
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: trace,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeTrace extends StatelessWidget {
  const _ThemeTrace();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final signals = [
      ('ACTIVE', palette.active),
      ('SIGNAL', palette.signal),
      ('ACK', palette.ack),
      ('WARNING', palette.warning),
      ('FAULT', palette.fault),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'LIVE THEME TRACE',
          style: TextStyle(
            color: palette.muted,
            fontFamily: 'monospace',
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.05,
          ),
        ),
        const SizedBox(height: YeknomSpacing.lg),
        for (final signal in signals) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: signal.$2,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: YeknomSpacing.sm),
              Expanded(
                child: Text(
                  signal.$1,
                  style: TextStyle(
                    color: palette.trace,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                colorHex(signal.$2),
                style: TextStyle(
                  color: palette.muted,
                  fontFamily: 'monospace',
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          if (signal != signals.last)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: palette.border),
            ),
        ],
      ],
    );
  }
}

class _SemanticSignalStrip extends StatelessWidget {
  const _SemanticSignalStrip();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final entries = [
      ('signal', palette.signal),
      ('active', palette.active),
      ('ack', palette.ack),
      ('warning', palette.warning),
      ('fault', palette.fault),
      ('trace', palette.trace),
    ];
    return YeknomSurface(
      padding: const EdgeInsets.all(YeknomSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = [
            for (final entry in entries)
              _SignalTile(name: entry.$1, color: entry.$2),
          ];
          if (constraints.maxWidth >= 850) {
            return Row(
              children: [
                for (var index = 0; index < tiles.length; index++) ...[
                  Expanded(child: tiles[index]),
                  if (index != tiles.length - 1)
                    const SizedBox(width: YeknomSpacing.xs),
                ],
              ],
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < tiles.length; index++) ...[
                  SizedBox(width: 142, child: tiles[index]),
                  if (index != tiles.length - 1)
                    const SizedBox(width: YeknomSpacing.xs),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(YeknomSpacing.md),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: YeknomRadii.control,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: YeknomRadii.pill,
            ),
          ),
          const SizedBox(height: YeknomSpacing.sm),
          Text(
            name,
            style: TextStyle(
              color: palette.trace,
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            colorHex(color),
            style: TextStyle(
              color: palette.muted,
              fontFamily: 'monospace',
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsSample extends StatefulWidget {
  const _ControlsSample();

  @override
  State<_ControlsSample> createState() => _ControlsSampleState();
}

class _ControlsSampleState extends State<_ControlsSample> {
  String _environment = 'Staging';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TextField(
          decoration: InputDecoration(
            labelText: '构建分支',
            hintText: '例如 release/1.4.0',
            prefixIcon: Icon(Icons.source_outlined),
          ),
        ),
        const SizedBox(height: YeknomSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Debug', label: Text('Debug')),
              ButtonSegment(value: 'Staging', label: Text('Staging')),
              ButtonSegment(value: 'Release', label: Text('Release')),
            ],
            selected: {_environment},
            onSelectionChanged: (selection) {
              setState(() {
                _environment = selection.first;
              });
            },
          ),
        ),
        const SizedBox(height: YeknomSpacing.lg),
        Wrap(
          spacing: YeknomSpacing.sm,
          runSpacing: YeknomSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 17),
              label: const Text('开始构建'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('保存预设'),
            ),
            TextButton(onPressed: () {}, child: const Text('重置')),
          ],
        ),
      ],
    );
  }
}

class _SystemStatusSample extends StatelessWidget {
  const _SystemStatusSample();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final entries = [
      ('构建服务', '响应正常', '在线', palette.ack),
      ('制品存储', '正在同步最新制品', '同步中', palette.active),
      ('签名证书', '14 天后到期', '需关注', palette.warning),
    ];
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entries[index].$1,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entries[index].$2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              YeknomStatusBadge(
                label: entries[index].$3,
                color: entries[index].$4,
              ),
            ],
          ),
          if (index != entries.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Divider(color: palette.border),
            ),
        ],
      ],
    );
  }
}
