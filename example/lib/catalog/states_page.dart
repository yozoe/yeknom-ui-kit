import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog_section.dart';
import 'catalog_widgets.dart';

enum _PreviewState { empty, error }

class StatesPage extends StatefulWidget {
  const StatesPage({super.key});

  @override
  State<StatesPage> createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage> {
  _PreviewState _preview = _PreviewState.empty;
  var _retryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogPageHeader(section: CatalogSection.states),
        CatalogPanel(
          title: '状态视图',
          description: '切换 empty/error，检查长文案、操作按钮和滚动边界。',
          icon: Icons.splitscreen_outlined,
          trailing: YeknomSegmentedTabs<_PreviewState>(
            key: const ValueKey('state_preview_selector'),
            segments: const [
              ButtonSegment(
                value: _PreviewState.empty,
                icon: Icon(Icons.inbox_outlined, size: 16),
                label: Text('Empty'),
              ),
              ButtonSegment(
                value: _PreviewState.error,
                icon: Icon(Icons.error_outline_rounded, size: 16),
                label: Text('Error'),
              ),
            ],
            selected: {_preview},
            onSelectionChanged: (selection) {
              setState(() {
                _preview = selection.first;
              });
            },
          ),
          child: _StatePreview(
            preview: _preview,
            retryCount: _retryCount,
            onRetry: () {
              setState(() {
                _retryCount += 1;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已发起第 $_retryCount 次重试'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: YeknomSpacing.lg),
        CatalogGrid(
          children: const [
            CatalogPanel(
              title: '状态谱系',
              description: '保持标签短、语义明确，并允许屏幕阅读器读取。',
              icon: Icons.linear_scale_rounded,
              child: _StatusSpectrum(),
            ),
            CatalogPanel(
              title: '反馈文案',
              description: '说明发生了什么，并给出可执行的下一步。',
              icon: Icons.notes_rounded,
              child: _FeedbackCopy(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatePreview extends StatelessWidget {
  const _StatePreview({
    required this.preview,
    required this.retryCount,
    required this.onRetry,
  });

  final _PreviewState preview;
  final int retryCount;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      height: 330,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.bench,
        border: Border.all(color: palette.border),
        borderRadius: YeknomRadii.medium,
      ),
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        child: preview == _PreviewState.empty
            ? const YeknomStateView.empty(
                key: ValueKey('empty_state_preview'),
                title: '暂无构建记录',
                message: '运行一次构建后，状态和制品会显示在这里。',
                icon: Icons.inventory_2_outlined,
              )
            : YeknomStateView.error(
                key: const ValueKey('error_state_preview'),
                title: '无法载入构建记录',
                message: retryCount == 0
                    ? '连接构建服务失败。检查网络后重试。'
                    : '第 $retryCount 次重试仍未成功，请检查服务地址。',
                actionLabel: '重新连接',
                onAction: onRetry,
                panelled: false,
              ),
      ),
    );
  }
}

class _StatusSpectrum extends StatelessWidget {
  const _StatusSpectrum();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final statuses = [
      ('Neutral', '等待操作', YeknomTone.neutral),
      ('Info', '正在同步', YeknomTone.info),
      ('Success', '同步完成', YeknomTone.success),
      ('Warning', '证书将过期', YeknomTone.warning),
      ('Danger', '构建失败', YeknomTone.danger),
      ('Accent', 'Release', YeknomTone.accent),
    ];
    return Column(
      children: [
        for (var index = 0; index < statuses.length; index++) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  statuses[index].$1,
                  style: TextStyle(
                    color: palette.muted,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              YeknomStatusBadge(
                label: statuses[index].$2,
                tone: statuses[index].$3,
              ),
            ],
          ),
          if (index != statuses.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: palette.border),
            ),
        ],
      ],
    );
  }
}

class _FeedbackCopy extends StatelessWidget {
  const _FeedbackCopy();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final entries = [
      (
        Icons.check_circle_outline_rounded,
        palette.ack,
        '构建完成',
        '制品已上传，可以复制下载链接。',
      ),
      (
        Icons.warning_amber_rounded,
        palette.warning,
        '需要更新证书',
        '当前证书将在 14 天后过期。',
      ),
      (
        Icons.error_outline_rounded,
        palette.fault,
        '上传被拒绝',
        '服务返回 403，请检查访问权限。',
      ),
    ];
    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.$1, color: entry.$2, size: 19),
                const SizedBox(width: YeknomSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.$3,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.$4,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
