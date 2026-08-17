import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              style: const TextStyle(fontSize: 12.5),
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
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byType(YeknomSearchField),
              matching: find.byType(TextField),
            ),
          )
          .style
          ?.fontSize,
      12.5,
    );
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

  testWidgets('buttons accept Material-style child content', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      _app(
        YeknomButton.text(
          onPressed: () => presses += 1,
          child: const Text('Details'),
        ),
      ),
    );

    await tester.tap(find.text('Details'));

    expect(presses, 1);
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
                  ButtonSegment(
                    value: 'one',
                    icon: Icon(Icons.looks_one_outlined),
                    label: Text('One'),
                  ),
                  ButtonSegment(
                    value: 'two',
                    icon: Icon(Icons.looks_two_outlined),
                    label: Text('Two'),
                  ),
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

    await tester.tap(find.byType(YeknomSwitch));
    await tester.tap(find.text('Two'));
    await tester.pump();

    expect(switched, isTrue);
    expect(selected, 'two');
    expect(find.byIcon(Icons.looks_one_outlined), findsOneWidget);
    expect(find.byIcon(Icons.looks_two_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(
      tester
          .widget<YeknomSwitch>(find.byType(YeknomSwitch))
          .materialTapTargetSize,
      MaterialTapTargetSize.shrinkWrap,
    );
    expect(tester.getSize(find.byType(YeknomSwitch)), const Size(42, 22));
  });

  testWidgets('switch supports keyboard, semantics and unified tile behavior', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var switchValue = false;
    var tileValue = false;

    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              YeknomSwitch(
                value: switchValue,
                semanticLabel: 'Desktop notifications',
                focusNode: focusNode,
                onChanged: (value) => setState(() => switchValue = value),
              ),
              YeknomSwitchTile(
                title: const Text('Build notifications'),
                value: tileValue,
                onChanged: (value) => setState(() => tileValue = value),
              ),
            ],
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.tap(find.text('Build notifications'));
    await tester.pump();

    expect(switchValue, isTrue);
    expect(tileValue, isTrue);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(YeknomSwitch), findsNWidgets(2));
    expect(
      tester.getSemantics(find.byType(YeknomSwitch).first),
      matchesSemantics(
        label: 'Desktop notifications',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('segmented tabs scroll safely with enlarged long labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(220, 180));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: Scaffold(
          body: YeknomSegmentedTabs<String>(
            segments: const [
              ButtonSegment(value: 'build', label: Text('Build history')),
              ButtonSegment(value: 'artifact', label: Text('Build artifacts')),
              ButtonSegment(value: 'archive', label: Text('Archive records')),
            ],
            selected: const {'build'},
            onSelectionChanged: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(YeknomSegmentedTabs<String>),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('list cards expose selection and preserve disabled behavior', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var activePresses = 0;
    var disabledPresses = 0;

    await tester.pumpWidget(
      _app(
        Column(
          children: [
            YeknomListCard(
              semanticLabel: 'Stable channel',
              title: const Text('Stable'),
              subtitle: const Text('Recommended'),
              selected: true,
              showChevron: true,
              onPressed: () => activePresses += 1,
            ),
            YeknomListCard(
              semanticLabel: 'Archived channel',
              title: const Text('Archived'),
              enabled: false,
              onPressed: () => disabledPresses += 1,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Stable'));
    await tester.tap(find.text('Archived'), warnIfMissed: false);

    expect(activePresses, 1);
    expect(disabledPresses, 0);
    expect(
      tester.getSemantics(find.byType(YeknomListCard).first),
      matchesSemantics(
        label: 'Stable channel',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(YeknomListCard).last),
      matchesSemantics(
        label: 'Archived channel',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    semantics.dispose();
  });

  testWidgets('dropdown uses formal options and returns selection', (
    tester,
  ) async {
    String? selected = 'macOS';
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(24),
            child: YeknomDropdown<String>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Platform'),
              options: const [
                YeknomDropdownOption(
                  value: 'macOS',
                  label: 'macOS',
                  leading: Icon(Icons.desktop_mac_outlined),
                ),
                YeknomDropdownOption(value: 'Web', label: 'Web'),
              ],
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Web').last);
    await tester.pumpAndSettle();

    expect(selected, 'Web');
    expect(find.text('Web'), findsOneWidget);
  });

  testWidgets('dropdown preserves validation and disabled state', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _app(
        Form(
          key: formKey,
          child: Column(
            children: [
              YeknomDropdown<String>(
                decoration: const InputDecoration(labelText: 'Required'),
                options: const [
                  YeknomDropdownOption(value: 'one', label: 'One'),
                ],
                validator: (value) => value == null ? 'Choose one' : null,
                onChanged: (_) {},
              ),
              const YeknomDropdown<String>(
                enabled: false,
                initialValue: 'locked',
                options: [
                  YeknomDropdownOption(value: 'locked', label: 'Locked'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Choose one'), findsOneWidget);
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>).last,
          )
          .onChanged,
      isNull,
    );
  });

  testWidgets('dialog separates regions and dangerous action closes it', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => YeknomButton.filled(
            label: const Text('Open dialog'),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) => YeknomDialog.danger(
                  title: const Text('Delete artifact?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    YeknomDialogAction(
                      variant: YeknomDialogActionVariant.danger,
                      label: const Text('Delete'),
                      onPressed: () {
                        confirmed = true;
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(YeknomDialog), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(YeknomDialog),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
    expect(find.byType(YeknomDialog), findsNothing);
  });

  testWidgets('list cards and dialogs fit narrow enlarged layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 440));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: YeknomTheme.dark(preset: YeknomColorPreset.sage),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: YeknomDialog(
            title: Text('Confirm a long operation'),
            content: Column(
              children: [
                YeknomListCard(
                  title: Text('A long list card title that wraps'),
                  subtitle: Text('Supporting details remain visible.'),
                  showChevron: true,
                ),
                SizedBox(height: 240),
              ],
            ),
            actions: [
              YeknomDialogAction(
                variant: YeknomDialogActionVariant.secondary,
                label: Text('Keep editing'),
              ),
              YeknomDialogAction(label: Text('Confirm operation')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('A long list card title that wraps'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
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
