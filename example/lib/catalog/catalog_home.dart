import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog_section.dart';
import 'components_page.dart';
import 'foundations_page.dart';
import 'overview_page.dart';
import 'states_page.dart';

class CatalogHome extends StatefulWidget {
  const CatalogHome({
    required this.themeMode,
    required this.colorPreset,
    required this.onThemeModeChanged,
    required this.onColorPresetChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final YeknomColorPreset colorPreset;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<YeknomColorPreset> onColorPresetChanged;

  @override
  State<CatalogHome> createState() => _CatalogHomeState();
}

class _CatalogHomeState extends State<CatalogHome> {
  CatalogSection _selected = CatalogSection.overview;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Scaffold(
      backgroundColor: palette.bench,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 960) {
              return _DesktopShell(
                selected: _selected,
                themeMode: widget.themeMode,
                colorPreset: widget.colorPreset,
                onSectionChanged: _select,
                onThemeModeChanged: widget.onThemeModeChanged,
                onColorPresetChanged: widget.onColorPresetChanged,
              );
            }
            return _CompactShell(
              selected: _selected,
              themeMode: widget.themeMode,
              colorPreset: widget.colorPreset,
              onSectionChanged: _select,
              onThemeModeChanged: widget.onThemeModeChanged,
              onColorPresetChanged: widget.onColorPresetChanged,
            );
          },
        ),
      ),
    );
  }

  void _select(CatalogSection section) {
    setState(() {
      _selected = section;
    });
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.selected,
    required this.themeMode,
    required this.colorPreset,
    required this.onSectionChanged,
    required this.onThemeModeChanged,
    required this.onColorPresetChanged,
  });

  final CatalogSection selected;
  final ThemeMode themeMode;
  final YeknomColorPreset colorPreset;
  final ValueChanged<CatalogSection> onSectionChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<YeknomColorPreset> onColorPresetChanged;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Row(
      children: [
        SizedBox(
          width: 242,
          child: ColoredBox(
            color: palette.module,
            child: CustomScrollView(
              key: const ValueKey('desktop_catalog_controls'),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandLockup(),
                      Divider(color: palette.border),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                        child: _NavigationLabel(),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverList.list(
                    children: [
                      for (final section in CatalogSection.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _NavigationButton(
                            section: section,
                            selected: section == selected,
                            onPressed: () => onSectionChanged(section),
                          ),
                        ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(color: palette.border),
                      Padding(
                        padding: const EdgeInsets.all(YeknomSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _ThemeLabel(),
                            const SizedBox(height: YeknomSpacing.sm),
                            _ThemeModeSelector(
                              themeMode: themeMode,
                              onChanged: onThemeModeChanged,
                            ),
                            const SizedBox(height: YeknomSpacing.md),
                            const _ColorLabel(),
                            const SizedBox(height: YeknomSpacing.sm),
                            _ColorPresetSelector(
                              preset: colorPreset,
                              onChanged: onColorPresetChanged,
                            ),
                            const SizedBox(height: YeknomSpacing.md),
                            Row(
                              children: [
                                const CatalogVersion(),
                                const Spacer(),
                                Icon(Icons.circle, color: palette.ack, size: 8),
                                const SizedBox(width: 6),
                                Text(
                                  'READY',
                                  style: TextStyle(
                                    color: palette.muted,
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, color: palette.border),
        Expanded(
          child: Column(
            children: [
              _WorkspaceHeader(section: selected),
              Expanded(child: _CatalogPage(section: selected)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactShell extends StatelessWidget {
  const _CompactShell({
    required this.selected,
    required this.themeMode,
    required this.colorPreset,
    required this.onSectionChanged,
    required this.onThemeModeChanged,
    required this.onColorPresetChanged,
  });

  final CatalogSection selected;
  final ThemeMode themeMode;
  final YeknomColorPreset colorPreset;
  final ValueChanged<CatalogSection> onSectionChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<YeknomColorPreset> onColorPresetChanged;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: BoxDecoration(
            color: palette.module,
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              const YeknomIconFrame(
                icon: Icons.design_services_outlined,
                size: 38,
                iconSize: 19,
              ),
              const SizedBox(width: YeknomSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yeknom UI Kit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 1),
                    const CatalogVersion(),
                  ],
                ),
              ),
              _ColorPresetSelector(
                compact: true,
                preset: colorPreset,
                onChanged: onColorPresetChanged,
              ),
              const SizedBox(width: 4),
              _ThemeModeSelector(
                compact: true,
                themeMode: themeMode,
                onChanged: onThemeModeChanged,
              ),
            ],
          ),
        ),
        ColoredBox(
          color: palette.module,
          child: SingleChildScrollView(
            key: const ValueKey('compact_catalog_navigation'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
            child: Row(
              children: [
                for (final section in CatalogSection.values) ...[
                  _CompactNavigationButton(
                    section: section,
                    selected: section == selected,
                    onPressed: () => onSectionChanged(section),
                  ),
                  if (section != CatalogSection.values.last)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        Divider(height: 1, color: palette.border),
        Expanded(child: _CatalogPage(section: selected)),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Row(
        children: [
          const YeknomIconFrame(
            icon: Icons.design_services_outlined,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: YeknomSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeknom UI Kit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  'VISUAL SYSTEM',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.signal,
                    fontFamily: 'monospace',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.15,
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

class _NavigationLabel extends StatelessWidget {
  const _NavigationLabel();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Text(
      'CATALOG',
      style: TextStyle(
        color: palette.muted,
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.15,
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.section,
    required this.selected,
    required this.onPressed,
  });

  final CatalogSection section;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final color = selected ? palette.active : palette.muted;
    return Material(
      color: selected ? palette.selected : Colors.transparent,
      borderRadius: YeknomRadii.control,
      child: InkWell(
        key: ValueKey('catalog_nav_${section.name}'),
        onTap: onPressed,
        borderRadius: YeknomRadii.control,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? palette.active : Colors.transparent,
                  borderRadius: YeknomRadii.pill,
                ),
              ),
              const SizedBox(width: 9),
              Icon(section.icon, color: color, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  section.label,
                  style: TextStyle(
                    color: selected ? palette.trace : palette.muted,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.active,
                  size: 17,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactNavigationButton extends StatelessWidget {
  const _CompactNavigationButton({
    required this.section,
    required this.selected,
    required this.onPressed,
  });

  final CatalogSection section;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Material(
      color: selected ? palette.selected : palette.field,
      shape: RoundedRectangleBorder(
        borderRadius: YeknomRadii.control,
        side: BorderSide(color: selected ? palette.active : palette.border),
      ),
      child: InkWell(
        key: ValueKey('catalog_nav_${section.name}'),
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(borderRadius: YeknomRadii.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                section.icon,
                color: selected ? palette.active : palette.muted,
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                section.label,
                style: TextStyle(
                  color: selected ? palette.trace : palette.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: palette.module,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Icon(section.icon, color: palette.signal, size: 18),
          const SizedBox(width: 9),
          Text(
            section.eyebrow,
            style: TextStyle(
              color: palette.trace,
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const Spacer(),
          const CatalogVersion(),
        ],
      ),
    );
  }
}

class _ThemeLabel extends StatelessWidget {
  const _ThemeLabel();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Text(
      'APPEARANCE',
      style: TextStyle(
        color: palette.muted,
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.05,
      ),
    );
  }
}

class _ColorLabel extends StatelessWidget {
  const _ColorLabel();

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Text(
      'COLOR COMBINATION',
      style: TextStyle(
        color: palette.muted,
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.05,
      ),
    );
  }
}

class _ColorPresetSelector extends StatelessWidget {
  const _ColorPresetSelector({
    required this.preset,
    required this.onChanged,
    this.compact = false,
  });

  final YeknomColorPreset preset;
  final ValueChanged<YeknomColorPreset> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final button = PopupMenuButton<YeknomColorPreset>(
      key: const ValueKey('color_preset_selector'),
      initialValue: preset,
      tooltip: '切换配色方案',
      position: PopupMenuPosition.under,
      offset: compact ? Offset.zero : const Offset(0, -246),
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in YeknomColorPreset.values)
          PopupMenuItem(
            key: ValueKey('color_preset_${option.name}'),
            value: option,
            child: Row(
              children: [
                _PresetSignal(preset: option),
                const SizedBox(width: YeknomSpacing.md),
                Text(option.label),
                if (option == preset) ...[
                  const Spacer(),
                  Icon(Icons.check, color: palette.active, size: 16),
                ],
              ],
            ),
          ),
      ],
      child: compact
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: _PresetSignal(preset: preset, compact: true),
            )
          : Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: palette.field,
                border: Border.all(color: palette.controlBorder),
                borderRadius: YeknomRadii.control,
              ),
              child: Row(
                children: [
                  _PresetSignal(preset: preset),
                  const SizedBox(width: YeknomSpacing.sm),
                  Expanded(
                    child: Text(
                      preset.label,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: palette.trace),
                    ),
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: palette.muted,
                    size: 16,
                  ),
                ],
              ),
            ),
    );

    return Semantics(
      button: true,
      label: '配色方案：${preset.label}',
      child: button,
    );
  }
}

class _PresetSignal extends StatelessWidget {
  const _PresetSignal({required this.preset, this.compact = false});

  final YeknomColorPreset preset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = YeknomPalette.fromPreset(
      preset,
      Theme.of(context).brightness,
    );
    final size = compact ? 7.0 : 8.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in [colors.active, colors.signal, colors.ack]) ...[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (color != colors.ack) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.themeMode,
    required this.onChanged,
    this.compact = false,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return YeknomSegmentedTabs<ThemeMode>(
      key: const ValueKey('theme_mode_selector'),
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          icon: const Icon(
            Icons.brightness_auto_outlined,
            key: ValueKey('theme_mode_system'),
            size: 16,
          ),
          label: compact ? null : const Text('自动'),
          tooltip: '跟随系统',
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(
            Icons.light_mode_outlined,
            key: ValueKey('theme_mode_light'),
            size: 16,
          ),
          label: compact ? null : const Text('浅色'),
          tooltip: '浅色主题',
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(
            Icons.dark_mode_outlined,
            key: ValueKey('theme_mode_dark'),
            size: 16,
          ),
          label: compact ? null : const Text('深色'),
          tooltip: '深色主题',
        ),
      ],
      selected: {themeMode},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

extension on YeknomColorPreset {
  String get label => switch (this) {
    YeknomColorPreset.workbench => '工作台',
    YeknomColorPreset.cobalt => '钴蓝',
    YeknomColorPreset.orchid => '兰紫',
    YeknomColorPreset.graphite => '石墨',
    YeknomColorPreset.obsidian => '黑曜',
    YeknomColorPreset.midnight => '午夜',
    YeknomColorPreset.blackberry => '紫黑',
    YeknomColorPreset.sage => '护眼',
  };
}

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Scrollbar(
        key: ValueKey(section),
        child: SingleChildScrollView(
          key: PageStorageKey(section),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: switch (section) {
                CatalogSection.overview => const OverviewPage(),
                CatalogSection.foundations => const FoundationsPage(),
                CatalogSection.components => const ComponentsPage(),
                CatalogSection.states => const StatesPage(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogVersion extends StatelessWidget {
  const CatalogVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Text(
      'v0.3.0',
      style: TextStyle(
        color: palette.muted,
        fontFamily: 'monospace',
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
