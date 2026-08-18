import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart';

import '../experience/example_experience.dart';
import '../experience/experience_switcher.dart';

class AppPreviewHome extends StatelessWidget {
  const AppPreviewHome({
    required this.experience,
    required this.themeMode,
    required this.colorPreset,
    required this.destination,
    required this.notificationsEnabled,
    required this.focusModeEnabled,
    required this.goalController,
    required this.onExperienceChanged,
    required this.onThemeModeChanged,
    required this.onColorPresetChanged,
    required this.onDestinationChanged,
    required this.onNotificationsChanged,
    required this.onFocusModeChanged,
    super.key,
  });

  final ExampleExperience experience;
  final ThemeMode themeMode;
  final YeknomColorPreset colorPreset;
  final int destination;
  final bool notificationsEnabled;
  final bool focusModeEnabled;
  final TextEditingController goalController;
  final ValueChanged<ExampleExperience> onExperienceChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<YeknomColorPreset> onColorPresetChanged;
  final ValueChanged<int> onDestinationChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onFocusModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final wide = constraints.maxWidth >= 1100 && textScale < 1.5;
        return Scaffold(
          key: const ValueKey('app_preview_shell'),
          appBar: AppBar(
            title: const _AppBrand(),
            actions: [
              if (wide)
                _WideNavigation(
                  selectedIndex: destination,
                  onDestinationSelected: onDestinationChanged,
                ),
              _ColorPresetButton(
                preset: colorPreset,
                onChanged: onColorPresetChanged,
              ),
              _ThemeModeButton(
                mode: themeMode,
                brightness: Theme.of(context).brightness,
                onChanged: onThemeModeChanged,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: switch (destination) {
            0 => _HomeExperiencePage(
              experience: experience,
              onExperienceChanged: onExperienceChanged,
              notificationsEnabled: notificationsEnabled,
              goalController: goalController,
              onNotificationsChanged: onNotificationsChanged,
              onApplySage: () {
                onColorPresetChanged(YeknomColorPreset.sage);
                _showMessage(context, '已切换到护眼配色');
              },
              onContinue: () => _showContinueSheet(context),
              onMessage: (message) => _showMessage(context, message),
            ),
            1 => _DiscoverExperiencePage(
              experience: experience,
              onExperienceChanged: onExperienceChanged,
              onMessage: (message) => _showMessage(context, message),
            ),
            _ => _ProfileExperiencePage(
              experience: experience,
              onExperienceChanged: onExperienceChanged,
              focusModeEnabled: focusModeEnabled,
              onFocusModeChanged: onFocusModeChanged,
              onMessage: (message) => _showMessage(context, message),
            ),
          },
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: destination,
                  onDestinationSelected: onDestinationChanged,
                  destinations: const [
                    NavigationDestination(
                      key: ValueKey('app_nav_home'),
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: '首页',
                    ),
                    NavigationDestination(
                      key: ValueKey('app_nav_discover'),
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded),
                      label: '探索',
                    ),
                    NavigationDestination(
                      key: ValueKey('app_nav_profile'),
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: '我的',
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showContinueSheet(BuildContext context) {
    return showYeknomAppSheet<void>(
      context: context,
      builder: (sheetContext) => YeknomAppSheet(
        title: const Text('App 体验实现说明'),
        actions: [
          YeknomButton.text(
            label: const Text('关闭'),
            onPressed: () => Navigator.pop(sheetContext),
          ),
          YeknomButton.filled(
            key: const ValueKey('app_sheet_confirm'),
            label: const Text('继续浏览'),
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () {
              Navigator.pop(sheetContext);
              _showMessage(context, '已返回 App 体验预览');
            },
          ),
        ],
        child: const Text('当前预览聚焦 6 个 App 专用组件、48 px 最小触控目标，以及桌面与移动两套导航布局。'),
      ),
    );
  }
}

class _AppBrand extends StatelessWidget {
  const _AppBrand();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: 'Yeknom App',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Yeknom',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'APP',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideNavigation extends StatelessWidget {
  const _WideNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_outlined, Icons.home_rounded, '首页'),
      (Icons.explore_outlined, Icons.explore_rounded, '探索'),
      (Icons.person_outline_rounded, Icons.person_rounded, '我的'),
    ];
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                key: ValueKey('app_wide_nav_$index'),
                container: true,
                label: destinations[index].$3,
                button: true,
                selected: selectedIndex == index,
                enabled: true,
                onTap: () => onDestinationSelected(index),
                excludeSemantics: true,
                child: TextButton.icon(
                  onPressed: () => onDestinationSelected(index),
                  style: TextButton.styleFrom(
                    foregroundColor: selectedIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    backgroundColor: Colors.transparent,
                  ),
                  icon: Icon(
                    selectedIndex == index
                        ? destinations[index].$2
                        : destinations[index].$1,
                    size: 18,
                  ),
                  label: Text(destinations[index].$3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorPresetButton extends StatelessWidget {
  const _ColorPresetButton({required this.preset, required this.onChanged});

  final YeknomColorPreset preset;
  final ValueChanged<YeknomColorPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<YeknomColorPreset>(
      key: const ValueKey('app_color_preset_selector'),
      initialValue: preset,
      tooltip: '切换配色方案',
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in YeknomColorPreset.values)
          CheckedPopupMenuItem(
            key: ValueKey('app_color_preset_${option.name}'),
            value: option,
            checked: option == preset,
            child: Text(option.appLabel),
          ),
      ],
      icon: const Icon(Icons.palette_outlined),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.mode,
    required this.brightness,
    required this.onChanged,
  });

  final ThemeMode mode;
  final Brightness brightness;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      key: const ValueKey('app_theme_toggle'),
      initialValue: mode,
      tooltip: '主题模式：${mode.appLabel}',
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in ThemeMode.values)
          CheckedPopupMenuItem(
            key: ValueKey('app_theme_mode_${option.name}'),
            value: option,
            checked: option == mode,
            child: Text(option.appLabel),
          ),
      ],
      icon: Icon(
        switch (mode) {
          ThemeMode.system => Icons.brightness_auto_outlined,
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
        },
        semanticLabel: mode == ThemeMode.system
            ? '当前系统外观为${brightness == Brightness.dark ? '深色' : '浅色'}'
            : null,
      ),
    );
  }
}

class _PageExperienceSwitcher extends StatelessWidget {
  const _PageExperienceSwitcher({
    required this.experience,
    required this.onChanged,
  });

  final ExampleExperience experience;
  final ValueChanged<ExampleExperience> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final switcher = ExperienceSwitcher(
          current: experience,
          onChanged: onChanged,
        );
        if (constraints.maxWidth < 720) {
          return SizedBox(
            key: const ValueKey('app_experience_switcher_frame'),
            width: double.infinity,
            child: switcher,
          );
        }
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(
            key: const ValueKey('app_experience_switcher_frame'),
            width: 360,
            child: switcher,
          ),
        );
      },
    );
  }
}

class _HomeExperiencePage extends StatelessWidget {
  const _HomeExperiencePage({
    required this.experience,
    required this.onExperienceChanged,
    required this.notificationsEnabled,
    required this.goalController,
    required this.onNotificationsChanged,
    required this.onApplySage,
    required this.onContinue,
    required this.onMessage,
  });

  final ExampleExperience experience;
  final ValueChanged<ExampleExperience> onExperienceChanged;
  final bool notificationsEnabled;
  final TextEditingController goalController;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onApplySage;
  final VoidCallback onContinue;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return YeknomAppPage(
      key: const ValueKey('app_home_page'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageExperienceSwitcher(
            experience: experience,
            onChanged: onExperienceChanged,
          ),
          const SizedBox(height: 24),
          YeknomAppHero(
            key: const ValueKey('app_signature_hero'),
            eyebrow: const Text('APP EXPERIENCE / UI KIT'),
            title: const Text('把组件系统，\n落到真实前端体验'),
            description: const Text(
              '用更宽松的布局、清晰的主任务和触控友好的控件，验证 UI Kit 在用户端场景中的表达。',
            ),
            actions: [
              YeknomButton.filled(
                key: const ValueKey('app_primary_action'),
                label: const Text('查看实现说明'),
                icon: const Icon(Icons.notes_rounded),
                onPressed: onContinue,
              ),
              YeknomButton.text(
                label: const Text('试用反馈提示'),
                onPressed: () => onMessage('这是 App Theme 下的反馈提示示例'),
              ),
            ],
            visual: const _AppExperienceSnapshot(),
          ),
          const SizedBox(height: 32),
          YeknomAppSection(
            title: const Text('体验构件'),
            description: const Text('围绕用户端首屏与连续操作，组合专用页面组件和共享基础控件。'),
            action: TextButton(
              onPressed: () => onMessage('当前页面展示 6 个 App 专用组件'),
              child: const Text('组件说明'),
            ),
            child: _ResponsiveFeatureCards(onMessage: onMessage),
          ),
          const SizedBox(height: 32),
          YeknomAppSection(
            title: const Text('实现检查'),
            description: const Text('每一项都对应当前 Example 中可以直接验证的布局、组件或主题能力。'),
            child: Column(
              children: [
                YeknomAppActionTile(
                  leading: const Icon(Icons.view_day_outlined),
                  title: const Text('响应式页面骨架'),
                  subtitle: const Text('YeknomAppPage · 安全区域与内容宽度'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => onMessage('页面骨架组件：YeknomAppPage'),
                ),
                const SizedBox(height: 12),
                YeknomAppActionTile(
                  leading: const Icon(Icons.view_agenda_outlined),
                  title: const Text('内容卡片与动作行'),
                  subtitle: const Text('YeknomAppCard + YeknomAppActionTile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => onMessage('内容组件支持指针、键盘与触控反馈'),
                ),
                const SizedBox(height: 12),
                YeknomAppActionTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('护眼配色预览'),
                  subtitle: const Text('Sage · 点击应用到当前预览'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onPressed: onApplySage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          YeknomAppSection(
            title: const Text('共享基础控件'),
            description: const Text('按钮与输入行为复用，外观由 App Theme 重新定义。'),
            child: YeknomAppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  YeknomTextField(
                    key: const ValueKey('app_text_field'),
                    controller: goalController,
                    decoration: const InputDecoration(
                      labelText: '记录本次体验检查',
                      hintText: '例如：确认移动端触控间距',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('状态提示开关'),
                    subtitle: const Text('演示 Switch 在 App Theme 下的触控与状态'),
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      YeknomButton.text(
                        key: const ValueKey('app_clear_input'),
                        label: const Text('清除'),
                        onPressed: () {
                          goalController.clear();
                          onMessage('输入已经清除');
                        },
                      ),
                      YeknomButton.filled(
                        label: const Text('保留预览设置'),
                        onPressed: () => onMessage('设置仅保留在本次预览中'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverExperiencePage extends StatelessWidget {
  const _DiscoverExperiencePage({
    required this.experience,
    required this.onExperienceChanged,
    required this.onMessage,
  });

  final ExampleExperience experience;
  final ValueChanged<ExampleExperience> onExperienceChanged;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return YeknomAppPage(
      key: const ValueKey('app_discover_page'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageExperienceSwitcher(
            experience: experience,
            onChanged: onExperienceChanged,
          ),
          const SizedBox(height: 24),
          YeknomAppHero(
            eyebrow: const Text('APP COMPONENTS / COMPOSITION'),
            title: const Text('组合用户端页面，\n不复制后台结构'),
            description: const Text(
              '用 Hero、Section、Card 和 ActionTile 建立内容顺序，让操作跟随任务而不是工具栏。',
            ),
            actions: [
              YeknomButton.filled(
                label: const Text('显示反馈示例'),
                onPressed: () => onMessage('组件组合反馈示例已显示'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          YeknomAppSection(
            title: const Text('两种内容组合'),
            description: const Text('相同基础能力，在用户端以阅读顺序和触控反馈组织。'),
            child: _ResponsiveFeatureCards(onMessage: onMessage),
          ),
        ],
      ),
    );
  }
}

class _ProfileExperiencePage extends StatelessWidget {
  const _ProfileExperiencePage({
    required this.experience,
    required this.onExperienceChanged,
    required this.focusModeEnabled,
    required this.onFocusModeChanged,
    required this.onMessage,
  });

  final ExampleExperience experience;
  final ValueChanged<ExampleExperience> onExperienceChanged;
  final bool focusModeEnabled;
  final ValueChanged<bool> onFocusModeChanged;
  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return YeknomAppPage(
      key: const ValueKey('app_profile_page'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageExperienceSwitcher(
            experience: experience,
            onChanged: onExperienceChanged,
          ),
          const SizedBox(height: 24),
          YeknomAppSection(
            title: const Text('预览偏好'),
            description: const Text('设置保持触控友好，并在 Workbench/App 往返后继续保留。'),
            child: YeknomAppCard(
              child: Column(
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.layers_outlined),
                    title: Text('App Experience'),
                    subtitle: Text('UI Kit 用户端组件预览'),
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('专注状态示例'),
                    subtitle: const Text('保留开关状态，用于验证体验往返'),
                    value: focusModeEnabled,
                    onChanged: onFocusModeChanged,
                  ),
                  const Divider(height: 24),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: YeknomButton.filled(
                      label: const Text('保留设置'),
                      onPressed: () => onMessage('设置已保留在本次预览中'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFeatureCards extends StatelessWidget {
  const _ResponsiveFeatureCards({required this.onMessage});

  final ValueChanged<String> onMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final first = _FeatureCard(
          icon: Icons.view_quilt_outlined,
          title: '首屏内容层级',
          description: 'Hero、Section 与 Card 共同定义主任务、说明和后续内容。',
          meta: '结构组合',
          onPressed: () => onMessage('首屏结构由 Hero、Section 与 Card 组成'),
        );
        final second = _FeatureCard(
          icon: Icons.touch_app_outlined,
          title: '触控与反馈',
          description: '控件保留至少 48 px 触控目标，并覆盖聚焦、悬停与按下状态。',
          meta: '交互规则',
          onPressed: () => onMessage('App 控件使用至少 48 px 的触控目标'),
        );

        if (constraints.maxWidth < 680) {
          return Column(children: [first, const SizedBox(height: 16), second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 20),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.meta,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String meta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return YeknomAppCard(
      onPressed: onPressed,
      semanticLabel: '$title，$description，$meta',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary, size: 24),
              const Spacer(),
              Text(
                meta,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '查看示例',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: scheme.primary),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppExperienceSnapshot extends StatelessWidget {
  const _AppExperienceSnapshot();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'App 体验组件概览',
      value: '6 个专用组件，48 px 最小触控目标，2 种响应式导航',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackMetrics =
                constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            const metrics = [
              _SnapshotMetric(value: '48 px', label: '最小触控目标'),
              _SnapshotMetric(value: '2 种', label: '响应式导航'),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'App 专用组件',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(Icons.layers_outlined, size: 20),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '6',
                      style: TextStyle(
                        fontSize: 40,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text('个核心构件'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (stackMetrics)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      metrics[0],
                      const SizedBox(height: 12),
                      metrics[1],
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: metrics[0]),
                      const SizedBox(width: 16),
                      Expanded(child: metrics[1]),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  const _SnapshotMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final inheritedStyle = DefaultTextStyle.of(context).style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: inheritedStyle.copyWith(
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: inheritedStyle.copyWith(fontSize: 13, height: 1.4)),
      ],
    );
  }
}

extension on YeknomColorPreset {
  String get appLabel => switch (this) {
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

extension on ThemeMode {
  String get appLabel => switch (this) {
    ThemeMode.system => '跟随系统',
    ThemeMode.light => '浅色',
    ThemeMode.dark => '深色',
  };
}
