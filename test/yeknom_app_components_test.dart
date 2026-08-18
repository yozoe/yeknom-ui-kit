import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_app.dart';

Widget _app(
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
  ValueListenable<double>? keyboardInset,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? YeknomAppTheme.light(),
    builder: (context, appChild) {
      Widget withMediaQuery(double inset) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            viewInsets: EdgeInsets.only(bottom: inset),
          ),
          child: appChild!,
        );
      }

      if (keyboardInset == null) return withMediaQuery(0);
      return ValueListenableBuilder<double>(
        valueListenable: keyboardInset,
        builder: (context, inset, child) => withMediaQuery(inset),
      );
    },
    home: Scaffold(body: child),
  );
}

BoxDecoration _animatedDecoration(WidgetTester tester, Finder ancestor) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: ancestor, matching: find.byType(AnimatedContainer)),
  );
  return container.decoration! as BoxDecoration;
}

double _contrastRatio(Color first, Color second) {
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

void main() {
  testWidgets(
    'Page, Hero, Section and ActionTile fit 320px with doubled text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _app(
          YeknomAppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                YeknomAppHero(
                  eyebrow: const Text('WORKSPACE'),
                  title: const Text('A clear place for every task'),
                  description: const Text(
                    'Review activity and continue where you left off.',
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Continue'),
                    ),
                  ],
                  visual: const Icon(Icons.auto_awesome_rounded, size: 64),
                ),
                const SizedBox(height: 32),
                YeknomAppSection(
                  title: const Text('Recent activity'),
                  description: const Text(
                    'Shortcuts stay readable when content grows.',
                  ),
                  action: TextButton(
                    onPressed: () {},
                    child: const Text('View all'),
                  ),
                  child: YeknomAppActionTile(
                    leading: const Icon(Icons.folder_open_rounded),
                    title: const Text('Open the current workspace'),
                    subtitle: const Text(
                      'Continue editing the latest project safely.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(YeknomAppPage), findsOneWidget);
      expect(find.byType(YeknomAppHero), findsOneWidget);
      expect(find.byType(YeknomAppSection), findsOneWidget);
      expect(find.byType(YeknomAppActionTile), findsOneWidget);
      final trailingContext = tester.element(
        find.byIcon(Icons.chevron_right_rounded),
      );
      expect(IconTheme.of(trailingContext).size, 20);
      expect(
        IconTheme.of(trailingContext).color,
        Theme.of(trailingContext).colorScheme.onSurfaceVariant,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AppPage relies on one desktop scrollbar with its default controller',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 320));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: YeknomAppTheme.light().copyWith(
            platform: TargetPlatform.macOS,
          ),
          home: const Scaffold(
            body: YeknomAppPage(
              child: SizedBox(
                height: 960,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('End of app page'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(Scrollable), findsOneWidget);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, 0);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Hero puts its visual to the right or below responsively', (
    tester,
  ) async {
    const titleKey = ValueKey('hero-title');
    const visualKey = ValueKey('hero-visual');

    Widget hero() {
      return YeknomAppHero(
        title: const Text('Workspace overview', key: titleKey),
        description: const Text('Everything important at a glance.'),
        visual: const SizedBox(
          key: visualKey,
          width: 120,
          height: 120,
          child: Icon(Icons.space_dashboard_rounded),
        ),
      );
    }

    await tester.binding.setSurfaceSize(const Size(1000, 620));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(Padding(padding: EdgeInsets.all(16), child: hero())),
    );
    await tester.pumpAndSettle();

    final wideTitle = tester.getCenter(find.byKey(titleKey));
    final wideVisual = tester.getCenter(find.byKey(visualKey));
    expect(wideVisual.dx, greaterThan(wideTitle.dx));
    expect((wideVisual.dy - wideTitle.dy).abs(), lessThan(180));

    await tester.binding.setSurfaceSize(const Size(540, 700));
    await tester.pumpWidget(
      _app(Padding(padding: EdgeInsets.all(16), child: hero())),
    );
    await tester.pumpAndSettle();

    final narrowTitle = tester.getCenter(find.byKey(titleKey));
    final narrowVisual = tester.getCenter(find.byKey(visualKey));
    expect(narrowVisual.dy, greaterThan(narrowTitle.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hero uses a restrained panel and focused App color roles', (
    tester,
  ) async {
    const actionKey = ValueKey('hero-action');
    const loadingActionKey = ValueKey('hero-loading-action');
    const visualKey = ValueKey('hero-color-visual');

    await tester.pumpWidget(
      _app(
        YeknomAppHero(
          title: const Text('Welcome'),
          description: const Text('A branded opening surface.'),
          actions: [
            FilledButton(
              key: actionKey,
              onPressed: () {},
              child: const Text('Start'),
            ),
            const YeknomButton.filled(
              key: loadingActionKey,
              label: Text('Loading'),
              loading: true,
            ),
          ],
          visual: const SizedBox(key: visualKey, height: 80),
        ),
      ),
    );

    final tokens = tester
        .element(find.byType(YeknomAppHero))
        .yeknomAppThemeTokens;
    final colorScheme = Theme.of(
      tester.element(find.byType(YeknomAppHero)),
    ).colorScheme;
    final actionTheme = FilledButtonTheme.of(
      tester.element(find.byKey(actionKey)),
    );
    final visualShelf = tester.widget<Container>(
      find
          .ancestor(of: find.byKey(visualKey), matching: find.byType(Container))
          .first,
    );
    final visualDecoration = visualShelf.decoration! as BoxDecoration;
    final heroContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(YeknomAppHero),
            matching: find.byType(Container),
          )
          .first,
    );
    final heroDecoration = heroContainer.decoration! as BoxDecoration;

    expect(
      actionTheme.style?.backgroundColor?.resolve(const {}),
      colorScheme.primary,
    );
    expect(
      actionTheme.style?.foregroundColor?.resolve(const {}),
      colorScheme.onPrimary,
    );
    expect(
      actionTheme.style?.minimumSize?.resolve(const {}),
      Size(tokens.minimumTapTarget, tokens.primaryButtonHeight),
    );
    final actionShape =
        actionTheme.style?.shape?.resolve(const {}) as RoundedRectangleBorder;
    expect(
      actionShape.borderRadius,
      BorderRadius.circular(tokens.controlRadius),
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.descendant(
              of: find.byKey(loadingActionKey),
              matching: find.byType(CircularProgressIndicator),
            ),
          )
          .color,
      actionTheme.style?.foregroundColor?.resolve({WidgetState.disabled}),
    );
    expect(
      actionTheme.style?.backgroundColor?.resolve({WidgetState.disabled}),
      isNot(colorScheme.primary),
    );
    expect(visualDecoration.color, Colors.transparent);
    expect(visualDecoration.border, isA<BorderDirectional>());
    expect((visualDecoration.border! as BorderDirectional).start.width, 1);
    expect(visualDecoration.boxShadow, isNull);
    expect(heroDecoration.color, tokens.heroBackground);
    expect(heroDecoration.gradient, isNull);
    expect(heroDecoration.boxShadow, isNull);
    expect(heroDecoration.border?.top.width, 1);
  });

  testWidgets('Hero distinguishes disabled states for every action type', (
    tester,
  ) async {
    const filledKey = ValueKey('hero-disabled-filled');
    const outlinedKey = ValueKey('hero-disabled-outlined');
    const textKey = ValueKey('hero-disabled-text');
    const enabledStates = <WidgetState>{};
    const disabledStates = {WidgetState.disabled};

    await tester.pumpWidget(
      _app(
        YeknomAppHero(
          title: const Text('Welcome'),
          description: const Text('Every action state remains legible.'),
          actions: const [
            FilledButton(
              key: filledKey,
              onPressed: null,
              child: Text('Filled disabled'),
            ),
            OutlinedButton(
              key: outlinedKey,
              onPressed: null,
              child: Text('Outlined disabled'),
            ),
            TextButton(
              key: textKey,
              onPressed: null,
              child: Text('Text disabled'),
            ),
          ],
        ),
      ),
    );

    final tokens = tester
        .element(find.byType(YeknomAppHero))
        .yeknomAppThemeTokens;
    final filledStyle = FilledButtonTheme.of(
      tester.element(find.byKey(filledKey)),
    ).style!;
    final outlinedStyle = OutlinedButtonTheme.of(
      tester.element(find.byKey(outlinedKey)),
    ).style!;
    final textStyle = TextButtonTheme.of(
      tester.element(find.byKey(textKey)),
    ).style!;

    expect(
      filledStyle.backgroundColor?.resolve(disabledStates),
      isNot(filledStyle.backgroundColor?.resolve(enabledStates)),
    );
    expect(
      filledStyle.foregroundColor?.resolve(disabledStates),
      isNot(filledStyle.foregroundColor?.resolve(enabledStates)),
    );
    expect(
      outlinedStyle.foregroundColor?.resolve(disabledStates),
      isNot(outlinedStyle.foregroundColor?.resolve(enabledStates)),
    );
    expect(
      outlinedStyle.side?.resolve(disabledStates),
      isNot(outlinedStyle.side?.resolve(enabledStates)),
    );
    expect(
      textStyle.foregroundColor?.resolve(disabledStates),
      isNot(textStyle.foregroundColor?.resolve(enabledStates)),
    );
    expect(
      filledStyle.minimumSize?.resolve(enabledStates),
      Size(tokens.minimumTapTarget, tokens.primaryButtonHeight),
    );
    expect(
      filledStyle.padding?.resolve(enabledStates),
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
    expect(
      (filledStyle.shape?.resolve(enabledStates) as RoundedRectangleBorder)
          .borderRadius,
      BorderRadius.circular(tokens.controlRadius),
    );
    expect(
      outlinedStyle.minimumSize?.resolve(enabledStates),
      Size(tokens.minimumTapTarget, tokens.primaryButtonHeight),
    );
  });

  testWidgets(
    'Hero visual scopes an opaque high-contrast progress indicator theme',
    (tester) async {
      const linearKey = ValueKey('hero-linear-progress');
      const circularKey = ValueKey('hero-circular-progress');
      const outsideKey = ValueKey('outside-linear-progress');
      const hostProgress = ProgressIndicatorThemeData(
        color: Colors.pink,
        linearTrackColor: Colors.amber,
        circularTrackColor: Colors.orange,
      );
      final hostTheme = YeknomAppTheme.light().copyWith(
        progressIndicatorTheme: hostProgress,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: hostTheme,
          home: Scaffold(
            body: Column(
              children: [
                YeknomAppHero(
                  title: const Text('Progress'),
                  description: const Text('A visible progress treatment.'),
                  visual: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      LinearProgressIndicator(key: linearKey, value: 0.4),
                      SizedBox(height: 16),
                      CircularProgressIndicator(key: circularKey, value: 0.4),
                    ],
                  ),
                ),
                const LinearProgressIndicator(key: outsideKey, value: 0.4),
              ],
            ),
          ),
        ),
      );

      final tokens = tester
          .element(find.byType(YeknomAppHero))
          .yeknomAppThemeTokens;
      final shelfTheme = ProgressIndicatorTheme.of(
        tester.element(find.byKey(linearKey)),
      );
      final outsideTheme = ProgressIndicatorTheme.of(
        tester.element(find.byKey(outsideKey)),
      );
      final track = shelfTheme.linearTrackColor!;

      expect(shelfTheme.color, tokens.heroForeground);
      expect(shelfTheme.circularTrackColor, track);
      expect(track.a, 1);
      expect(_contrastRatio(shelfTheme.color!, track), greaterThanOrEqualTo(3));
      expect(outsideTheme.color, hostProgress.color);
      expect(outsideTheme.linearTrackColor, hostProgress.linearTrackColor);
      expect(outsideTheme.circularTrackColor, hostProgress.circularTrackColor);
    },
  );

  testWidgets(
    'AppCard supports pointer, Enter, Space, focus and disabled semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      const cardKey = ValueKey('interactive-card');
      var presses = 0;

      Widget card({required bool enabled}) {
        return Center(
          child: YeknomAppCard(
            key: cardKey,
            semanticLabel: 'Open project',
            enabled: enabled,
            onPressed: () => presses += 1,
            child: const Text('Project Atlas'),
          ),
        );
      }

      await tester.pumpWidget(_app(card(enabled: true)));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byKey(cardKey)),
        matchesSemantics(
          label: 'Open project',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        _animatedDecoration(
          tester,
          find.byKey(cardKey),
        ).boxShadow?.single.blurRadius,
        8,
      );
      expect(
        _animatedDecoration(tester, find.byKey(cardKey)).border?.top.width,
        1,
      );

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      await pointer.moveTo(tester.getCenter(find.byKey(cardKey)));
      await tester.pumpAndSettle();
      expect(
        _animatedDecoration(
          tester,
          find.byKey(cardKey),
        ).boxShadow?.single.blurRadius,
        12,
      );
      await pointer.moveTo(Offset.zero);
      await pointer.removePointer();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        _animatedDecoration(tester, find.byKey(cardKey)).boxShadow,
        hasLength(1),
      );
      expect(
        _animatedDecoration(tester, find.byKey(cardKey)).border?.top.color,
        tester
            .element(find.byKey(cardKey))
            .yeknomAppThemeTokens
            .interactiveAccent,
      );
      expect(
        _animatedDecoration(tester, find.byKey(cardKey)).border?.top.width,
        2,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.tap(find.byKey(cardKey));
      await tester.pump();
      expect(presses, 3);

      await tester.pumpWidget(_app(card(enabled: false)));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byKey(cardKey)),
        matchesSemantics(
          label: 'Open project',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.descendant(
                of: find.byKey(cardKey),
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .opacity,
        0.46,
      );
      expect(
        _animatedDecoration(tester, find.byKey(cardKey)).boxShadow,
        hasLength(1),
      );

      await tester.tap(find.byKey(cardKey), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 3);
      semantics.dispose();
    },
  );

  testWidgets('interactive AppCard keeps a 48px target with compact content', (
    tester,
  ) async {
    const cardKey = ValueKey('compact-interactive-card');

    await tester.pumpWidget(
      _app(
        Center(
          child: YeknomAppCard(
            key: cardKey,
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    final tokens = tester.element(find.byKey(cardKey)).yeknomAppThemeTokens;
    expect(
      tester.getSize(find.byKey(cardKey)),
      Size(tokens.minimumTapTarget, tokens.minimumTapTarget),
    );
  });

  testWidgets('AppActionTile preserves interaction and disabled semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    const tileKey = ValueKey('action-tile');
    var presses = 0;

    Widget tile({required bool enabled}) {
      return Center(
        child: SizedBox(
          width: 420,
          child: YeknomAppActionTile(
            key: tileKey,
            semanticLabel: 'Open notifications',
            enabled: enabled,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Review recent updates'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onPressed: () => presses += 1,
          ),
        ),
      );
    }

    await tester.pumpWidget(_app(tile(enabled: true)));
    await tester.pumpAndSettle();
    final tileContext = tester.element(find.byKey(tileKey));
    final tokens = tileContext.yeknomAppThemeTokens;
    expect(
      tester.getSemantics(find.byKey(tileKey)),
      matchesSemantics(
        label: 'Open notifications',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      _animatedDecoration(tester, find.byKey(tileKey)).color,
      tokens.surface,
    );
    expect(
      _animatedDecoration(tester, find.byKey(tileKey)).border?.top.width,
      1,
    );
    expect(_animatedDecoration(tester, find.byKey(tileKey)).boxShadow, isNull);

    await tester.tap(find.byKey(tileKey));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      _animatedDecoration(tester, find.byKey(tileKey)).boxShadow?.single.color,
      tokens.interactiveAccent,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 2);

    await tester.pumpWidget(_app(tile(enabled: false)));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(tileKey)),
      matchesSemantics(
        label: 'Open notifications',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    expect(_animatedDecoration(tester, find.byKey(tileKey)).boxShadow, isNull);
    await tester.tap(find.byKey(tileKey), warnIfMissed: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 2);
    semantics.dispose();
  });

  testWidgets(
    'AppSheet fits a short window, follows the keyboard and remains scrollable',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(320, 260));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final keyboardInset = ValueNotifier<double>(0);
      addTearDown(keyboardInset.dispose);
      const lastLineKey = ValueKey('last-sheet-line');
      Future<void>? routeResult;

      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () {
                    routeResult = showYeknomAppSheet<void>(
                      context: context,
                      builder: (sheetContext) => YeknomAppSheet(
                        closeTooltip: 'Close app sheet',
                        title: const Text('Review changes'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Done'),
                          ),
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var index = 0; index < 16; index++)
                              Padding(
                                key: index == 15 ? lastLineKey : null,
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Change ${index + 1} has enough detail to read.',
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Open sheet'),
                ),
              );
            },
          ),
          textScaler: const TextScaler.linear(2),
          keyboardInset: keyboardInset,
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      final sheetFinder = find.byType(YeknomAppSheet);
      expect(
        find.byKey(const ValueKey('yeknom_app_sheet_drag_handle')),
        findsOneWidget,
      );
      expect(
        tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
        isFalse,
      );
      expect(
        tester.getSemantics(find.text('Review changes')),
        matchesSemantics(
          label: 'Review changes',
          isHeader: true,
          namesRoute: true,
        ),
      );
      final sheetMaterial = find
          .descendant(of: sheetFinder, matching: find.byType(Material))
          .first;
      final bottomBeforeKeyboard = tester.getBottomRight(sheetMaterial).dy;

      keyboardInset.value = 64;
      await tester.pumpAndSettle();
      final bottomWithKeyboard = tester.getBottomRight(sheetMaterial).dy;
      expect(bottomWithKeyboard, lessThan(bottomBeforeKeyboard));
      expect(bottomWithKeyboard, lessThanOrEqualTo(196.1));

      final lastLineBeforeScroll = tester
          .getTopLeft(find.byKey(lastLineKey))
          .dy;
      await tester.drag(
        find.descendant(
          of: sheetFinder,
          matching: find.byType(SingleChildScrollView),
        ),
        const Offset(0, -160),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(lastLineKey)).dy,
        lessThan(lastLineBeforeScroll),
      );
      expect(tester.takeException(), isNull);

      final closeButton = find.byTooltip('Close app sheet');
      await tester.ensureVisible(closeButton);
      await tester.pumpAndSettle();
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(sheetFinder, findsNothing);
      await routeResult;
      semantics.dispose();
    },
  );

  testWidgets('AppSheet route and body honor BottomSheetTheme overrides', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const barrierColor = Color(0x99223344);
    const handleColor = Color(0xFF8A2BE2);
    const handleSize = Size(44, 6);
    const constraints = BoxConstraints(maxWidth: 480);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    );
    final baseTheme = YeknomAppTheme.light();
    final customTheme = baseTheme.copyWith(
      bottomSheetTheme: baseTheme.bottomSheetTheme.copyWith(
        modalBarrierColor: barrierColor,
        modalElevation: 13,
        constraints: constraints,
        shape: shape,
        dragHandleColor: handleColor,
        dragHandleSize: handleSize,
      ),
    );

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () {
                showYeknomAppSheet<void>(
                  context: context,
                  builder: (sheetContext) => YeknomAppSheet(
                    title: const Text('Theme-aware sheet'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Close themed sheet'),
                      ),
                    ],
                    child: const Text('Uses host geometry and route styling.'),
                  ),
                );
              },
              child: const Text('Open themed sheet'),
            ),
          ),
        ),
        theme: customTheme,
      ),
    );

    await tester.tap(find.text('Open themed sheet'));
    await tester.pumpAndSettle();

    final sheetFinder = find.byType(YeknomAppSheet);
    final sheetMaterialFinder = find
        .descendant(of: sheetFinder, matching: find.byType(Material))
        .first;
    final sheetMaterial = tester.widget<Material>(sheetMaterialFinder);
    final handleFinder = find.byKey(
      const ValueKey('yeknom_app_sheet_drag_handle'),
    );
    final handle = tester.widget<Container>(handleFinder);

    expect(tester.getSize(sheetFinder).width, 480);
    expect(sheetMaterial.elevation, 0);
    expect(sheetMaterial.shape, shape);
    expect(tester.getSize(handleFinder), handleSize);
    expect((handle.decoration! as BoxDecoration).color, handleColor);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ModalBarrier && widget.color == barrierColor,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Close themed sheet'));
    await tester.pumpAndSettle();
  });

  testWidgets('showYeknomAppSheet returns the value used to close it', (
    tester,
  ) async {
    Future<String?>? routeResult;

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            return Center(
              child: FilledButton(
                onPressed: () {
                  routeResult = showYeknomAppSheet<String>(
                    context: context,
                    builder: (sheetContext) => YeknomAppSheet(
                      showCloseButton: false,
                      title: const Text('Confirm'),
                      actions: [
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(sheetContext, 'confirmed'),
                          child: const Text('Confirm action'),
                        ),
                      ],
                      child: const Text('Finish this action?'),
                    ),
                  );
                },
                child: const Text('Show helper'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show helper'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm action'));
    await tester.pumpAndSettle();

    expect(await routeResult, 'confirmed');
    expect(find.byType(YeknomAppSheet), findsNothing);
  });
}
