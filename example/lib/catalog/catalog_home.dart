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
    required this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
                onSectionChanged: _select,
                onThemeModeChanged: widget.onThemeModeChanged,
              );
            }
            return _CompactShell(
              selected: _selected,
              themeMode: widget.themeMode,
              onSectionChanged: _select,
              onThemeModeChanged: widget.onThemeModeChanged,
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
    required this.onSectionChanged,
    required this.onThemeModeChanged,
  });

  final CatalogSection selected;
  final ThemeMode themeMode;
  final ValueChanged<CatalogSection> onSectionChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Row(
      children: [
        SizedBox(
          width: 242,
          child: ColoredBox(
            color: palette.module,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BrandLockup(),
                Divider(color: palette.border),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: _NavigationLabel(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
    required this.onSectionChanged,
    required this.onThemeModeChanged,
  });

  final CatalogSection selected;
  final ThemeMode themeMode;
  final ValueChanged<CatalogSection> onSectionChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  'VISUAL SYSTEM',
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
        color: palette.faint,
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
        color: palette.faint,
        fontFamily: 'monospace',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.05,
      ),
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
    return SegmentedButton<ThemeMode>(
      key: const ValueKey('theme_mode_selector'),
      showSelectedIcon: false,
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
      'v0.2.3',
      style: TextStyle(
        color: palette.faint,
        fontFamily: 'monospace',
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
