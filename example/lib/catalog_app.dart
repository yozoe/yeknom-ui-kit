import 'package:flutter/material.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart' show YeknomAppTheme;
import 'package:yeknom_ui_kit/yeknom_workbench.dart';

import 'app_preview/app_preview_home.dart';
import 'catalog/catalog_home.dart';
import 'catalog/catalog_section.dart';
import 'experience/example_experience.dart';

class YeknomCatalogApp extends StatefulWidget {
  const YeknomCatalogApp({super.key});

  @override
  State<YeknomCatalogApp> createState() => _YeknomCatalogAppState();
}

class _YeknomCatalogAppState extends State<YeknomCatalogApp> {
  final _appGoalController = TextEditingController();
  ThemeMode _themeMode = ThemeMode.system;
  YeknomColorPreset _colorPreset = YeknomColorPreset.workbench;
  ExampleExperience _experience = ExampleExperience.workbench;
  CatalogSection _catalogSection = CatalogSection.overview;
  int _appDestination = 0;
  bool _appNotificationsEnabled = true;
  bool _appFocusModeEnabled = false;

  @override
  void dispose() {
    _appGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appExperience = _experience == ExampleExperience.app;
    return MaterialApp(
      navigatorKey: YeknomToast.navigatorKey,
      title: 'Yeknom UI Kit',
      debugShowCheckedModeBanner: false,
      theme: appExperience
          ? YeknomAppTheme.light(preset: _colorPreset)
          : YeknomWorkbenchTheme.light(preset: _colorPreset),
      darkTheme: appExperience
          ? YeknomAppTheme.dark(preset: _colorPreset)
          : YeknomWorkbenchTheme.dark(preset: _colorPreset),
      themeMode: _themeMode,
      home: KeyedSubtree(
        key: ValueKey(_experience),
        child: appExperience
            ? AppPreviewHome(
                experience: _experience,
                themeMode: _themeMode,
                colorPreset: _colorPreset,
                destination: _appDestination,
                notificationsEnabled: _appNotificationsEnabled,
                focusModeEnabled: _appFocusModeEnabled,
                goalController: _appGoalController,
                onExperienceChanged: _setExperience,
                onThemeModeChanged: _setThemeMode,
                onColorPresetChanged: _setColorPreset,
                onDestinationChanged: (destination) {
                  setState(() {
                    _appDestination = destination;
                  });
                },
                onNotificationsChanged: (enabled) {
                  setState(() {
                    _appNotificationsEnabled = enabled;
                  });
                },
                onFocusModeChanged: (enabled) {
                  setState(() {
                    _appFocusModeEnabled = enabled;
                  });
                },
              )
            : CatalogHome(
                selected: _catalogSection,
                experience: _experience,
                themeMode: _themeMode,
                colorPreset: _colorPreset,
                onSectionChanged: (section) {
                  setState(() {
                    _catalogSection = section;
                  });
                },
                onExperienceChanged: _setExperience,
                onThemeModeChanged: _setThemeMode,
                onColorPresetChanged: _setColorPreset,
              ),
      ),
    );
  }

  void _setExperience(ExampleExperience experience) {
    if (_experience == experience) return;
    setState(() {
      _experience = experience;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _setColorPreset(YeknomColorPreset preset) {
    setState(() {
      _colorPreset = preset;
    });
  }
}
