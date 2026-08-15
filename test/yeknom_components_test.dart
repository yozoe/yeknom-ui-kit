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
}
