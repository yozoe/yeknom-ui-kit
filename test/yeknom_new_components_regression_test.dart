import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: YeknomTheme.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('dropdown derives behavior and visuals from one enabled state', (
    tester,
  ) async {
    var changes = 0;

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            YeknomDropdown<String>(
              initialValue: 'locked',
              enabled: false,
              options: const [
                YeknomDropdownOption(value: 'locked', label: 'Locked'),
              ],
              onChanged: (_) => changes += 1,
            ),
            YeknomDropdown<String>(
              decoration: const InputDecoration(enabled: false),
              initialValue: 'decorated',
              options: const [
                YeknomDropdownOption(value: 'decorated', label: 'Decorated'),
              ],
              onChanged: (_) => changes += 1,
            ),
            YeknomDropdown<String>(
              hint: const Text('No options'),
              options: const [],
              onChanged: (_) => changes += 1,
            ),
          ],
        ),
      ),
    );

    final fields = tester.widgetList<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(fields, hasLength(3));
    expect(fields.every((field) => field.onChanged == null), isTrue);

    final decorators = tester.widgetList<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(decorators, hasLength(3));
    expect(
      decorators.every((decorator) => !decorator.decoration.enabled),
      isTrue,
    );

    final palette = YeknomPalette.fromBrightness(Brightness.light);
    expect(
      tester.widget<Text>(find.text('Locked')).style?.color,
      palette.faint,
    );
    expect(
      tester.widget<Text>(find.text('Decorated')).style?.color,
      palette.faint,
    );
    expect(changes, 0);
  });

  testWidgets('disabled list card blocks trailing pointer and focus', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var cardPresses = 0;
    var trailingPresses = 0;
    final trailingFocusNode = FocusNode();
    addTearDown(trailingFocusNode.dispose);

    await tester.pumpWidget(
      _app(
        YeknomListCard(
          enabled: false,
          semanticLabel: 'Archived card',
          title: const Text('Archived'),
          onPressed: () => cardPresses += 1,
          trailing: IconButton(
            focusNode: trailingFocusNode,
            tooltip: 'More actions',
            onPressed: () => trailingPresses += 1,
            icon: const Icon(Icons.more_horiz),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('More actions'), warnIfMissed: false);
    trailingFocusNode.requestFocus();
    await tester.pump();

    expect(cardPresses, 0);
    expect(trailingPresses, 0);
    expect(trailingFocusNode.canRequestFocus, isFalse);
    expect(trailingFocusNode.hasFocus, isFalse);
    expect(
      tester
          .getSemantics(find.byType(IconButton))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    semantics.dispose();
  });

  testWidgets('list card label preserves trailing action semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _app(
        YeknomListCard(
          semanticLabel: 'Build artifact',
          title: const Text('Artifact 42'),
          onPressed: () {},
          trailing: IconButton(
            tooltip: 'More actions',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Build artifact'), findsOneWidget);
    final trailingData = tester
        .getSemantics(find.byType(IconButton))
        .getSemanticsData();
    expect(trailingData.tooltip, 'More actions');
    expect(trailingData.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('list card exposes selection only for selectable cards', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            YeknomListCard(
              key: const ValueKey('plain_card'),
              title: const Text('Open details'),
              onPressed: () {},
            ),
            YeknomListCard(
              key: const ValueKey('selectable_card'),
              title: const Text('Preview channel'),
              selectable: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(const ValueKey('plain_card'))),
      matchesSemantics(
        label: 'Open details',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('selectable_card'))),
      matchesSemantics(
        label: 'Preview channel',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: false,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('dialog scrolls all regions and labels its close action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2.5)),
          child: child!,
        ),
        home: Scaffold(
          body: YeknomDialog(
            title: const Text(
              'Confirm this unusually long operation before continuing',
            ),
            content: const Text(
              'Review all settings before starting the operation.',
            ),
            onClose: () {},
            actions: const [
              YeknomDialogAction(label: Text('Return to configuration')),
              YeknomDialogAction(label: Text('Save another draft')),
              YeknomDialogAction(label: Text('Confirm and continue')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(IconButton)).getSemanticsData().tooltip,
      'Close',
    );

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(YeknomDialog),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    semantics.dispose();
  });
}
