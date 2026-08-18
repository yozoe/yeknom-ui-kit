import 'package:flutter/material.dart';

enum ExampleExperience {
  workbench(
    label: '管理后台',
    description: '高密度的数据与操作工作台',
    icon: Icons.space_dashboard_outlined,
  ),
  app(
    label: '前端应用',
    description: '内容优先的用户端产品体验',
    icon: Icons.auto_awesome_outlined,
  );

  const ExampleExperience({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}
