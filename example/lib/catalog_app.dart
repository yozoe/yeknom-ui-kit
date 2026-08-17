import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

import 'catalog/catalog_home.dart';

class YeknomCatalogApp extends StatefulWidget {
  const YeknomCatalogApp({super.key});

  @override
  State<YeknomCatalogApp> createState() => _YeknomCatalogAppState();
}

class _YeknomCatalogAppState extends State<YeknomCatalogApp> {
  ThemeMode _themeMode = ThemeMode.system;
  YeknomColorPreset _colorPreset = YeknomColorPreset.workbench;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: YeknomToast.navigatorKey,
      title: 'Yeknom UI Kit',
      debugShowCheckedModeBanner: false,
      theme: YeknomTheme.light(preset: _colorPreset),
      darkTheme: YeknomTheme.dark(preset: _colorPreset),
      themeMode: _themeMode,
      home: CatalogHome(
        themeMode: _themeMode,
        colorPreset: _colorPreset,
        onThemeModeChanged: (mode) {
          setState(() {
            _themeMode = mode;
          });
        },
        onColorPresetChanged: (preset) {
          setState(() {
            _colorPreset = preset;
          });
        },
      ),
    );
  }
}
