import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart'
    show YeknomAppCard, YeknomAppHero, YeknomAppThemeTokens, YeknomAppSheet;
import 'package:yeknom_ui_kit/yeknom_workbench.dart';
import 'package:yeknom_ui_kit_example/catalog_app.dart';

void main() {
  tearDown(YeknomToast.clear);

  testWidgets('desktop catalog navigates and switches theme', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();

    expect(find.text('把工作台视觉，\n变成可复用的系统'), findsOneWidget);
    expect(find.byType(YeknomTextField), findsOneWidget);
    expect(find.byType(YeknomSegmentedTabs<String>), findsOneWidget);
    expect(find.byType(YeknomSegmentedTabs<ThemeMode>), findsOneWidget);
    expect(find.byType(YeknomButton), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('catalog_nav_components')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('experience_app')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('catalog_nav_components')));
    await tester.pump();

    expect(find.text('Surface 与标题'), findsOneWidget);
    expect(find.text('状态徽标'), findsOneWidget);
    expect(find.text('分段 Tab'), findsOneWidget);
    expect(find.text('Toast 通知'), findsOneWidget);
    expect(find.byType(YeknomSearchField), findsOneWidget);
    expect(find.byType(YeknomSkeleton), findsNWidgets(3));

    await tester.tap(find.byKey(const ValueKey('color_preset_selector')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final eyeCarePreset = find.byKey(const ValueKey('color_preset_sage'));
    await tester.ensureVisible(eyeCarePreset);
    await tester.pump();
    await tester.tap(eyeCarePreset.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      materialApp.theme?.extension<YeknomPalette>()?.active,
      YeknomPalette.fromPreset(YeknomColorPreset.sage, Brightness.light).active,
    );

    final successToastButton = find.text('成功 Toast');
    await tester.ensureVisible(successToastButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(successToastButton);
    await tester.pump();
    expect(find.text('操作已成功完成'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme_mode_dark')));
    await tester.pump(const Duration(milliseconds: 300));

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.darkTheme?.extension<YeknomPalette>()?.dark, isTrue);
    expect(
      materialApp.darkTheme?.extension<YeknomPalette>()?.active,
      YeknomPalette.fromPreset(YeknomColorPreset.sage, Brightness.dark).active,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between workbench and app experience', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('catalog_nav_components')));
    await tester.pump();
    expect(find.text('Surface 与标题'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app_preview_shell')), findsOneWidget);
    expect(find.byType(YeknomAppHero), findsOneWidget);
    expect(find.byType(YeknomAppCard), findsWidgets);
    expect(find.text('Yeknom'), findsOneWidget);
    expect(find.text('APP'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('48 px'), findsOneWidget);
    expect(find.text('2 种'), findsOneWidget);
    final experienceFrame = find.byKey(
      const ValueKey('app_experience_switcher_frame'),
    );
    expect(tester.getSize(experienceFrame).width, 360);
    expect(
      tester.getTopRight(experienceFrame).dx,
      closeTo(
        tester.getTopRight(find.byKey(const ValueKey('app_signature_hero'))).dx,
        0.1,
      ),
    );
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.extension<YeknomAppThemeTokens>(), isNotNull);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('app_wide_nav_0'))),
      matchesSemantics(
        label: '首页',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('app_wide_nav_1')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('app_wide_nav_1'))),
      matchesSemantics(
        label: '探索',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('experience_workbench')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey('workbench_desktop_shell')),
      findsOneWidget,
    );
    expect(find.text('Surface 与标题'), findsOneWidget);
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('app state survives a round trip through workbench', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    final input = find.descendant(
      of: find.byKey(const ValueKey('app_text_field')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(input);
    await tester.enterText(input, '保留这次预览进度');

    final notifications = find.widgetWithText(SwitchListTile, '状态提示开关');
    await tester.ensureVisible(notifications);
    await tester.tap(notifications);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(notifications).value, isFalse);

    await tester.tap(find.byKey(const ValueKey('app_wide_nav_2')));
    await tester.pumpAndSettle();
    final focusMode = find.widgetWithText(SwitchListTile, '专注状态示例');
    await tester.tap(focusMode);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(focusMode).value, isTrue);

    await tester.tap(find.byKey(const ValueKey('experience_workbench')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('workbench_desktop_shell')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('app_profile_page')), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, '专注状态示例'))
          .value,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('app_wide_nav_0')));
    await tester.pumpAndSettle();
    final restoredInput = find.descendant(
      of: find.byKey(const ValueKey('app_text_field')),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(restoredInput).controller?.text,
      '保留这次预览进度',
    );
    expect(
      tester
          .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, '状态提示开关'))
          .value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('workbench desktop fits doubled text without truncating mode', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('workbench_desktop_shell')),
      findsOneWidget,
    );
    expect(find.text('管理后台'), findsOneWidget);
    expect(find.text('前端应用'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact app experience and sheet fit enlarged text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app_nav_home')), findsOneWidget);
    expect(find.byKey(const ValueKey('app_signature_hero')), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('app_experience_switcher_frame')))
          .width,
      closeTo(
        tester.getSize(find.byKey(const ValueKey('app_signature_hero'))).width,
        0.1,
      ),
    );
    expect(tester.takeException(), isNull);

    final primaryAction = find.byKey(const ValueKey('app_primary_action'));
    await tester.ensureVisible(primaryAction);
    await tester.pumpAndSettle();
    await tester.tap(primaryAction);
    await tester.pumpAndSettle();

    expect(find.byType(YeknomAppSheet), findsOneWidget);
    expect(find.text('App 体验实现说明'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app controls preserve input and three theme modes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('app_color_preset_selector')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckedPopupMenuItem<YeknomColorPreset>>(
            find.byKey(const ValueKey('app_color_preset_workbench')),
          )
          .checked,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('app_color_preset_workbench')));
    await tester.pumpAndSettle();

    final savedSage = find.text('护眼配色预览');
    await tester.ensureVisible(savedSage);
    await tester.tap(savedSage);
    await tester.pumpAndSettle();
    expect(find.text('已切换到护眼配色'), findsOneWidget);
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme
          ?.extension<YeknomPalette>()
          ?.active,
      YeknomPalette.fromPreset(YeknomColorPreset.sage, Brightness.light).active,
    );

    final input = find.descendant(
      of: find.byKey(const ValueKey('app_text_field')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(input);
    await tester.enterText(input, '准备下一次发布');
    await tester.tap(find.byKey(const ValueKey('app_clear_input')));
    await tester.pump();
    expect(tester.widget<TextField>(input).controller?.text, isEmpty);

    await tester.tap(find.byKey(const ValueKey('app_theme_toggle')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckedPopupMenuItem<ThemeMode>>(
            find.byKey(const ValueKey('app_theme_mode_system')),
          )
          .checked,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('app_theme_mode_dark')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.byKey(const ValueKey('app_theme_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('app_theme_mode_system')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('app adapts navigation and experience labels for large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app_wide_nav_0')), findsNothing);
    expect(find.byKey(const ValueKey('app_nav_home')), findsOneWidget);
    expect(find.text('管理后台'), findsOneWidget);
    expect(find.text('前端应用'), findsOneWidget);
  });

  testWidgets('minimum app width keeps doubled experience labels intact', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('experience_app')));
    await tester.pumpAndSettle();

    final workbenchLabel = tester.widget<Text>(find.text('管理后台'));
    final appLabel = tester.widget<Text>(find.text('前端应用'));
    expect(workbenchLabel.overflow, isNot(TextOverflow.ellipsis));
    expect(appLabel.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('minimum compact width keeps foundations in bounds', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();

    final foundations = find.byKey(const ValueKey('catalog_nav_foundations'));
    await tester.ensureVisible(foundations);
    await tester.tap(foundations);
    await tester.pumpAndSettle();

    expect(find.text('间距比例'), findsOneWidget);
    expect(find.text('32 px'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short desktop height keeps appearance controls scrollable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 360));
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pump();

    expect(
      find.byKey(const ValueKey('desktop_catalog_controls')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('color_preset_selector')),
      240,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('desktop_catalog_controls')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('compact catalog fits enlarged text and previews an error', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const YeknomCatalogApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('compact_catalog_navigation')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('catalog_nav_states')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Error'));
    await tester.pumpAndSettle();

    expect(find.text('无法载入构建记录'), findsOneWidget);
    expect(find.text('重新连接'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
