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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yeknom UI Kit',
      debugShowCheckedModeBanner: false,
      theme: YeknomTheme.light(),
      darkTheme: YeknomTheme.dark(),
      themeMode: _themeMode,
      home: CatalogHome(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) {
          setState(() {
            _themeMode = mode;
          });
        },
      ),
    );
  }
}
