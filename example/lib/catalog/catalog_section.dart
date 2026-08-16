import 'package:flutter/material.dart';

enum CatalogSection {
  overview(
    label: '总览',
    eyebrow: 'OVERVIEW',
    description: '在一个页面检查视觉语言和交互基线。',
    icon: Icons.dashboard_outlined,
  ),
  foundations(
    label: '基础',
    eyebrow: 'FOUNDATIONS',
    description: '查看语义色、间距与圆角 token。',
    icon: Icons.palette_outlined,
  ),
  components(
    label: '控件',
    eyebrow: 'COMPONENTS',
    description: '检查表单、面板和信息呈现方式。',
    icon: Icons.widgets_outlined,
  ),
  states(
    label: '状态',
    eyebrow: 'FEEDBACK',
    description: '检查状态徽标、空态、错误态和操作反馈。',
    icon: Icons.monitor_heart_outlined,
  );

  const CatalogSection({
    required this.label,
    required this.eyebrow,
    required this.description,
    required this.icon,
  });

  final String label;
  final String eyebrow;
  final String description;
  final IconData icon;
}
