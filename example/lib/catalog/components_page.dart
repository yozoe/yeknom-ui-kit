import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog_section.dart';
import 'catalog_widgets.dart';

class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogPageHeader(section: CatalogSection.components),
        CatalogGrid(
          children: const [
            CatalogPanel(
              title: 'Surface 与标题',
              description: '容器和标题共同建立模块层级。',
              icon: Icons.view_agenda_outlined,
              child: _SurfaceSample(),
            ),
            CatalogPanel(
              title: '状态徽标',
              description: '颜色来自 tone，也可以显式传入语义色。',
              icon: Icons.sell_outlined,
              child: _BadgeSample(),
            ),
            CatalogPanel(
              title: '信息行',
              description: '适合详情、确认页和只读信息。',
              icon: Icons.table_rows_outlined,
              child: _InfoRowSample(),
            ),
            CatalogPanel(
              title: '图标容器',
              description: '统一功能入口与状态图标的尺寸和底色。',
              icon: Icons.grid_view_rounded,
              child: _IconFrameSample(),
            ),
            CatalogPanel(
              title: '按钮',
              description: '通过主题统一层级、密度与圆角。',
              icon: Icons.smart_button_outlined,
              child: _ButtonSample(),
            ),
            CatalogPanel(
              title: '输入控件',
              description: '文本、搜索和开关共享一致的焦点与语义行为。',
              icon: Icons.input_rounded,
              child: _InputSample(),
            ),
            CatalogPanel(
              title: '分段 Tab',
              description: '适合少量互斥视图或参数的快速切换。',
              icon: Icons.view_week_outlined,
              child: _SegmentedTabsSample(),
            ),
            CatalogPanel(
              title: '加载与骨架',
              description: '区分局部内容占位和整体加载状态。',
              icon: Icons.hourglass_top_rounded,
              child: _LoadingSample(),
            ),
          ],
        ),
      ],
    );
  }
}

class _SurfaceSample extends StatelessWidget {
  const _SurfaceSample();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return YeknomSurface(
      backgroundColor: palette.raised,
      borderRadius: YeknomRadii.medium,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          YeknomSectionHeader(
            icon: Icons.source_outlined,
            title: 'Git 分支',
            description: '选择本次构建使用的来源分支。',
            trailing: CatalogCode('required'),
          ),
          SizedBox(height: YeknomSpacing.lg),
          YeknomTextField(
            decoration: InputDecoration(
              hintText: 'release/1.4.0',
              prefixIcon: Icon(Icons.commit_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeSample extends StatelessWidget {
  const _BadgeSample();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: YeknomSpacing.sm,
      runSpacing: YeknomSpacing.sm,
      children: [
        YeknomStatusBadge(label: '等待中'),
        YeknomStatusBadge(label: '构建中', tone: YeknomTone.info),
        YeknomStatusBadge(label: '已完成', tone: YeknomTone.success),
        YeknomStatusBadge(label: '需关注', tone: YeknomTone.warning),
        YeknomStatusBadge(label: '失败', tone: YeknomTone.danger),
        YeknomStatusBadge(label: 'Release', tone: YeknomTone.accent),
      ],
    );
  }
}

class _InfoRowSample extends StatelessWidget {
  const _InfoRowSample();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Column(
      children: [
        const YeknomInfoRow(label: '版本', value: '1.4.0+482'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: YeknomSpacing.sm),
          child: Divider(color: palette.border),
        ),
        const YeknomInfoRow(label: '分支', value: 'release/1.4.0'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: YeknomSpacing.sm),
          child: Divider(color: palette.border),
        ),
        const YeknomInfoRow(label: '制品', value: 'yeknom-desktop-arm64.dmg'),
      ],
    );
  }
}

class _IconFrameSample extends StatelessWidget {
  const _IconFrameSample();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Wrap(
      spacing: YeknomSpacing.md,
      runSpacing: YeknomSpacing.md,
      children: [
        const YeknomIconFrame(
          icon: Icons.construction_rounded,
          semanticLabel: '构建',
        ),
        YeknomIconFrame(
          icon: Icons.cloud_done_outlined,
          color: palette.ack,
          semanticLabel: '同步完成',
        ),
        YeknomIconFrame(
          icon: Icons.warning_amber_rounded,
          color: palette.warning,
          semanticLabel: '警告',
        ),
        YeknomIconFrame(
          icon: Icons.error_outline_rounded,
          color: palette.fault,
          semanticLabel: '错误',
        ),
      ],
    );
  }
}

class _ButtonSample extends StatelessWidget {
  const _ButtonSample();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: YeknomSpacing.sm,
      runSpacing: YeknomSpacing.sm,
      children: [
        YeknomButton.filled(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_rounded, size: 17),
          label: const Text('主操作'),
        ),
        YeknomButton.outlined(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded, size: 16),
          label: const Text('次操作'),
        ),
        YeknomButton.text(onPressed: () {}, label: const Text('文字操作')),
        const YeknomIconButton(
          onPressed: null,
          tooltip: '禁用操作',
          icon: Icon(Icons.more_horiz_rounded),
        ),
      ],
    );
  }
}

class _InputSample extends StatefulWidget {
  const _InputSample();

  @override
  State<_InputSample> createState() => _InputSampleState();
}

class _InputSampleState extends State<_InputSample> {
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const YeknomTextField(
          decoration: InputDecoration(
            labelText: '名称',
            hintText: '输入预设名称',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        const SizedBox(height: YeknomSpacing.md),
        const YeknomSearchField(hintText: '搜索分支或制品', clearTooltip: '清空搜索'),
        const SizedBox(height: YeknomSpacing.md),
        DropdownMenu<String>(
          initialSelection: 'macOS',
          expandedInsets: EdgeInsets.zero,
          label: const Text('目标平台'),
          leadingIcon: const Icon(Icons.devices_outlined),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'macOS', label: 'macOS'),
            DropdownMenuEntry(value: 'Web', label: 'Web'),
          ],
          onSelected: (_) {},
        ),
        const SizedBox(height: YeknomSpacing.sm),
        YeknomSwitchTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('完成后通知'),
          subtitle: const Text('展示开关与列表项的主题继承'),
          value: _notify,
          onChanged: (value) {
            setState(() {
              _notify = value;
            });
          },
        ),
      ],
    );
  }
}

class _SegmentedTabsSample extends StatefulWidget {
  const _SegmentedTabsSample();

  @override
  State<_SegmentedTabsSample> createState() => _SegmentedTabsSampleState();
}

class _SegmentedTabsSampleState extends State<_SegmentedTabsSample> {
  String _selection = 'builds';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: YeknomSegmentedTabs<String>(
        segments: const [
          ButtonSegment(
            value: 'builds',
            icon: Icon(Icons.construction_outlined, size: 16),
            label: Text('构建'),
          ),
          ButtonSegment(
            value: 'artifacts',
            icon: Icon(Icons.inventory_2_outlined, size: 16),
            label: Text('制品'),
          ),
        ],
        selected: {_selection},
        onSelectionChanged: (selection) {
          setState(() => _selection = selection.single);
        },
      ),
    );
  }
}

class _LoadingSample extends StatelessWidget {
  const _LoadingSample();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            YeknomSkeleton.circle(size: 36),
            SizedBox(width: YeknomSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YeknomSkeleton.line(width: 150),
                  SizedBox(height: YeknomSpacing.sm),
                  YeknomSkeleton.line(width: 220, height: 9),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: YeknomSpacing.lg),
        SizedBox(
          height: 120,
          child: YeknomLoadingView(title: '正在读取构建记录', semanticLabel: '构建记录加载中'),
        ),
      ],
    );
  }
}
