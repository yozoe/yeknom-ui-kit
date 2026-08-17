import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? YeknomTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

AnimatedContainer _thumb(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(YeknomSwitch),
          matching: find.byType(AnimatedContainer),
        ),
      )
      .singleWhere(
        (container) =>
            (container.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
}

void main() {
  testWidgets(
    'padded target is 48 square while shrink-wrap keeps the track size',
    (tester) async {
      await tester.pumpWidget(
        _app(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              YeknomSwitch(
                key: const ValueKey('padded'),
                value: false,
                onChanged: (_) {},
              ),
              YeknomSwitch(
                key: const ValueKey('shrink-wrap'),
                value: false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(const ValueKey('padded'))),
        const Size(48, 48),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('shrink-wrap'))),
        const Size(42, 22),
      );
    },
  );

  testWidgets('switch theme supplies tap target size before the app theme', (
    tester,
  ) async {
    final baseTheme = YeknomTheme.light();
    final theme = baseTheme.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      switchTheme: baseTheme.switchTheme.copyWith(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    await tester.pumpWidget(
      _app(YeknomSwitch(value: false, onChanged: (_) {}), theme: theme),
    );

    expect(tester.getSize(find.byType(YeknomSwitch)), const Size(42, 22));
  });

  testWidgets(
    'horizontal drag changes the controlled value in both directions',
    (tester) async {
      var value = false;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => YeknomSwitch(
              value: value,
              onChanged: (nextValue) => setState(() => value = nextValue),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(YeknomSwitch), const Offset(24, 0));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      await tester.drag(find.byType(YeknomSwitch), const Offset(-24, 0));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    },
  );

  testWidgets(
    'pressed thumb grows as a circle instead of shifting its bounds',
    (tester) async {
      await tester.pumpWidget(
        _app(YeknomSwitch(value: false, onChanged: (_) {})),
      );

      expect(
        _thumb(tester).constraints,
        const BoxConstraints.tightFor(width: 16, height: 16),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(YeknomSwitch)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        _thumb(tester).constraints,
        const BoxConstraints.tightFor(width: 18, height: 18),
      );

      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('switch tile exposes one focus stop and one merged toggle node', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final beforeFocus = FocusNode();
    final afterFocus = FocusNode();
    addTearDown(beforeFocus.dispose);
    addTearDown(afterFocus.dispose);
    var value = false;

    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                focusNode: beforeFocus,
                onPressed: () {},
                child: const Text('Before'),
              ),
              YeknomSwitchTile(
                title: const Text('Build notifications'),
                value: value,
                onChanged: (nextValue) {
                  setState(() => value = nextValue);
                },
              ),
              TextButton(
                focusNode: afterFocus,
                onPressed: () {},
                child: const Text('After'),
              ),
            ],
          ),
        ),
      ),
    );

    beforeFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(value, isTrue);
    expect(
      tester.getSemantics(find.byType(YeknomSwitchTile)),
      matchesSemantics(
        label: 'Build notifications',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
        hasSelectedState: true,
        isFocused: true,
        isFocusable: true,
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(afterFocus.hasFocus, isTrue);

    semantics.dispose();
  });
}
