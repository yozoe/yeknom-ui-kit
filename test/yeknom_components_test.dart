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
  testWidgets('surface and section header render supplied content', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const YeknomSurface(
          child: YeknomSectionHeader(
            icon: Icons.source_outlined,
            title: 'Git branch',
            description: 'Select a source branch',
          ),
        ),
      ),
    );

    expect(find.text('Git branch'), findsOneWidget);
    expect(find.text('Select a source branch'), findsOneWidget);
    expect(find.byIcon(Icons.source_outlined), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Git branch')),
      matchesSemantics(label: 'Git branch', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('status badge exposes one live-region semantics label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const Center(
          child: YeknomStatusBadge(
            label: 'Complete',
            tone: YeknomTone.success,
            semanticsLabel: 'Build status: complete',
            liveRegion: true,
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(YeknomStatusBadge)),
      matchesSemantics(label: 'Build status: complete', isLiveRegion: true),
    );
    semantics.dispose();
  });

  testWidgets('error state invokes its injected action', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _app(
        YeknomStateView.error(
          title: 'Could not load',
          message: 'Connection failed',
          actionLabel: 'Retry',
          onAction: () => retries += 1,
        ),
      ),
    );

    await tester.tap(find.text('Retry'));

    expect(retries, 1);
    expect(find.text('Connection failed'), findsOneWidget);
  });

  testWidgets('state view and info row fit a narrow, enlarged layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(300, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
        home: const Scaffold(
          body: Column(
            children: [
              Expanded(
                child: YeknomStateView.empty(
                  title: 'No tasks',
                  message: 'Transfer progress appears here.',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: YeknomInfoRow(label: 'Version', value: '1.2.3+45'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('No tasks'), findsOneWidget);
    expect(find.text('1.2.3+45'), findsOneWidget);
  });

  testWidgets('info row associates its label and value for semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const YeknomInfoRow(label: 'Version', value: '1.2.3+45')),
    );

    expect(
      tester.getSemantics(find.byType(SelectableText)).label,
      'Version: 1.2.3+45',
    );
    semantics.dispose();
  });

  testWidgets('text and search fields preserve input callbacks', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var submitted = '';
    var changed = '';
    var cleared = 0;

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            YeknomTextField(
              key: const ValueKey('text'),
              controller: controller,
              onSubmitted: (value) => submitted = value,
            ),
            YeknomSearchField(
              key: const ValueKey('search'),
              clearTooltip: 'Clear query',
              onChanged: (value) => changed = value,
              onClear: () => cleared += 1,
            ),
          ],
        ),
      ),
    );

    await tester.enterText(find.byKey(const ValueKey('text')), 'release/2.0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.enterText(find.byKey(const ValueKey('search')), 'artifact');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear query'));
    await tester.pump();

    expect(controller.text, 'release/2.0');
    expect(submitted, 'release/2.0');
    expect(changed, '');
    expect(cleared, 1);
  });

  testWidgets('loading buttons remain disabled and expose progress semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await tester.pumpWidget(
      _app(
        YeknomButton.filled(
          label: const Text('Build'),
          loading: true,
          loadingSemanticsLabel: 'Building',
          onPressed: () => presses += 1,
        ),
      ),
    );

    await tester.tap(find.byType(YeknomButton));

    expect(presses, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(YeknomButton)),
      matchesSemantics(
        label: 'Building',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    semantics.dispose();
  });

  testWidgets('icon button preserves compact layout parameters', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const YeknomIconButton(
          icon: Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 30, height: 30),
          visualDensity: VisualDensity.compact,
          color: Colors.red,
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.tooltip, isNull);
    expect(button.padding, EdgeInsets.zero);
    expect(button.constraints?.maxWidth, 30);
    expect(button.visualDensity, VisualDensity.compact);
    expect(button.color, Colors.red);
  });

  testWidgets('switches and segmented tabs return user selections', (
    tester,
  ) async {
    var switched = false;
    var selected = 'one';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              YeknomSwitch(
                value: switched,
                semanticLabel: 'Notifications',
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) => setState(() => switched = value),
              ),
              YeknomSegmentedTabs<String>(
                segments: const [
                  ButtonSegment(value: 'one', label: Text('One')),
                  ButtonSegment(value: 'two', label: Text('Two')),
                ],
                selected: {selected},
                onSelectionChanged: (value) {
                  setState(() => selected = value.single);
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Two'));
    await tester.pump();

    expect(switched, isTrue);
    expect(selected, 'two');
    expect(
      tester.widget<Switch>(find.byType(Switch)).materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
  });

  testWidgets('skeleton and loading view support reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: Column(
              children: [
                YeknomSkeleton.line(
                  width: 180,
                  semanticLabel: 'Loading summary',
                ),
                Expanded(
                  child: YeknomLoadingView(
                    title: 'Loading builds',
                    semanticLabel: 'Builds are loading',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Loading builds'), findsOneWidget);
    expect(find.byType(YeknomSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
