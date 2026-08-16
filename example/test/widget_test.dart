import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';
import 'package:yeknom_ui_kit_example/catalog_app.dart';

void main() {
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
    expect(
      find.byKey(const ValueKey('catalog_nav_components')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('catalog_nav_components')));
    await tester.pump();

    expect(find.text('Surface 与标题'), findsOneWidget);
    expect(find.text('状态徽标'), findsOneWidget);
    expect(find.text('分段 Tab'), findsOneWidget);
    expect(find.byType(YeknomSearchField), findsOneWidget);
    expect(find.byType(YeknomSkeleton), findsNWidgets(3));

    await tester.tap(find.byKey(const ValueKey('theme_mode_dark')));
    await tester.pump(const Duration(milliseconds: 300));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.darkTheme?.extension<YeknomPalette>()?.dark, isTrue);
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
