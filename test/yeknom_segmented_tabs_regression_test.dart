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

void main() {
  test('rejects invalid segment and selection configurations', () {
    expect(
      () => YeknomSegmentedTabs<int>(
        segments: const [],
        selected: const {1},
        onSelectionChanged: (_) {},
      ),
      throwsAssertionError,
    );
    expect(
      () => YeknomSegmentedTabs<int>(
        segments: const [ButtonSegment(value: 1, label: Text('One'))],
        selected: const {},
        onSelectionChanged: (_) {},
      ),
      throwsAssertionError,
    );
    expect(
      () => YeknomSegmentedTabs<int>(
        segments: const [
          ButtonSegment(value: 1, label: Text('One')),
          ButtonSegment(value: 2, label: Text('Two')),
        ],
        selected: const {1, 2},
        onSelectionChanged: (_) {},
      ),
      throwsAssertionError,
    );
  });

  testWidgets('does not report a selection that has not changed', (
    tester,
  ) async {
    var callbackCount = 0;
    Set<String>? lastSelection;

    await tester.pumpWidget(
      _app(
        YeknomSegmentedTabs<String>(
          segments: const [
            ButtonSegment(value: 'one', label: Text('One')),
            ButtonSegment(value: 'two', label: Text('Two')),
          ],
          selected: const {'one'},
          onSelectionChanged: (selection) {
            callbackCount += 1;
            lastSelection = selection;
          },
        ),
      ),
    );

    await tester.tap(find.text('One'));
    await tester.pump();
    expect(callbackCount, 0);

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(callbackCount, 1);
    expect(lastSelection, {'two'});
  });

  testWidgets('preserves widget and ambient segmented button styles', (
    tester,
  ) async {
    const themedShape = BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    );
    const themedIcon = Icon(Icons.star_rounded);
    const widgetStyle = ButtonStyle(
      elevation: WidgetStatePropertyAll(7),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      iconAlignment: IconAlignment.end,
    );
    final theme = YeknomTheme.light().copyWith(
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          iconSize: WidgetStatePropertyAll(23),
          shape: WidgetStatePropertyAll(themedShape),
          mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.grab),
        ),
        selectedIcon: themedIcon,
      ),
    );

    await tester.pumpWidget(
      _app(
        YeknomSegmentedTabs<String>(
          segments: const [
            ButtonSegment(value: 'one', label: Text('One')),
            ButtonSegment(value: 'two', label: Text('Two')),
          ],
          selected: const {'one'},
          showSelectedIcon: true,
          style: widgetStyle,
          onSelectionChanged: (_) {},
        ),
        theme: theme,
      ),
    );

    final nativeFinder = find.byType(SegmentedButton<String>);
    final native = tester.widget<SegmentedButton<String>>(nativeFinder);
    final effectiveTheme = SegmentedButtonTheme.of(
      tester.element(nativeFinder),
    );
    final materials = tester.widgetList<Material>(
      find.descendant(of: nativeFinder, matching: find.byType(Material)),
    );

    expect(native.style, same(widgetStyle));
    expect(effectiveTheme.style?.iconSize?.resolve(const {}), 23);
    expect(effectiveTheme.style?.shape?.resolve(const {}), themedShape);
    expect(
      effectiveTheme.style?.backgroundColor?.resolve({WidgetState.selected}),
      isNotNull,
    );
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(materials.any((material) => material.elevation == 7), isTrue);
  });

  testWidgets('strengthens selected fill and label without an underline', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        YeknomSegmentedTabs<String>(
          segments: const [
            ButtonSegment(value: 'one', label: Text('One')),
            ButtonSegment(value: 'two', label: Text('Two')),
          ],
          selected: const {'one'},
          onSelectionChanged: (_) {},
        ),
      ),
    );

    final nativeFinder = find.byType(SegmentedButton<String>);
    final context = tester.element(nativeFinder);
    final palette = YeknomPalette.of(context);
    final style = SegmentedButtonTheme.of(context).style!;
    final selectedBackground = style.backgroundColor!.resolve({
      WidgetState.selected,
    })!;
    final selectedText = style.textStyle!.resolve({WidgetState.selected})!;
    final unselectedText = style.textStyle!.resolve(const {})!;

    expect(
      _contrast(selectedBackground, palette.field),
      greaterThan(_contrast(palette.selected, palette.field)),
    );
    expect(
      selectedText.fontWeight!.value,
      greaterThan(unselectedText.fontWeight!.value),
    );
    expect(selectedText.fontWeight!.value, greaterThanOrEqualTo(700));
    expect(
      style.side!.resolve({WidgetState.selected})!.style,
      BorderStyle.none,
    );
  });

  testWidgets('shows a high-contrast keyboard focus ring inside the track', (
    tester,
  ) async {
    final previousStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() {
      FocusManager.instance.highlightStrategy = previousStrategy;
    });

    await tester.pumpWidget(
      _app(
        YeknomSegmentedTabs<String>(
          segments: const [
            ButtonSegment(value: 'one', label: Text('One')),
            ButtonSegment(value: 'two', label: Text('Two')),
          ],
          selected: const {'one'},
          onSelectionChanged: (_) {},
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final tabsFinder = find.byType(YeknomSegmentedTabs<String>);
    final track = tester.widget<AnimatedContainer>(
      find.descendant(of: tabsFinder, matching: find.byType(AnimatedContainer)),
    );
    final decoration = track.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    final palette = YeknomPalette.of(tester.element(tabsFinder));

    expect(border.top.width, 2);
    expect(border.top.color, isNot(Colors.transparent));
    expect(_contrast(border.top.color, palette.field), greaterThanOrEqualTo(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps an icon-only segment icon beside its selected icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        YeknomSegmentedTabs<String>(
          segments: const [
            ButtonSegment(value: 'home', icon: Icon(Icons.home_outlined)),
            ButtonSegment(value: 'search', icon: Icon(Icons.search_outlined)),
          ],
          selected: const {'home'},
          showSelectedIcon: true,
          selectedIcon: const Icon(Icons.check_rounded),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.search_outlined), findsOneWidget);
  });

  testWidgets('does not add intrinsic sizing widgets in either direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YeknomSegmentedTabs<String>(
              segments: const [
                ButtonSegment(value: 'one', label: Text('One')),
                ButtonSegment(value: 'two', label: Text('Two')),
              ],
              selected: const {'one'},
              onSelectionChanged: (_) {},
            ),
            YeknomSegmentedTabs<String>(
              direction: Axis.vertical,
              segments: const [
                ButtonSegment(value: 'one', label: Text('One')),
                ButtonSegment(value: 'two', label: Text('Two')),
              ],
              selected: const {'one'},
              onSelectionChanged: (_) {},
            ),
          ],
        ),
      ),
    );

    expect(find.byType(IntrinsicHeight), findsNothing);
    expect(find.byType(IntrinsicWidth), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

double _contrast(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
