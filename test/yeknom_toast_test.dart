import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeknom_ui_kit/yeknom_ui_kit.dart';

void main() {
  tearDown(() {
    YeknomToast.clear();
    YeknomToast.displayDuration = const Duration(seconds: 2);
    YeknomToast.maxWidth = 480;
    YeknomToast.defaultBackgroundColor = Colors.black87;
    YeknomToast.successBackgroundColor = Colors.green.shade700;
    YeknomToast.errorBackgroundColor = Colors.red.shade700;
    YeknomToast.warningBackgroundColor = Colors.orange.shade700;
    YeknomToast.defaultTextColor = Colors.white;
  });

  testWidgets('shows and dismisses through navigatorKey', (tester) async {
    YeknomToast.displayDuration = const Duration(milliseconds: 50);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: YeknomToast.navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    YeknomToast.showSuccess('Saved');
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('shows after context initialization', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    YeknomToast.init(context);
    YeknomToast.showWarning('Check input');
    await tester.pump();

    expect(find.text('Check input'), findsOneWidget);
  });

  testWidgets('supports default and per-call colors', (tester) async {
    const defaultColor = Color(0xFF123456);
    const overrideColor = Color(0xFF654321);
    const textColor = Color(0xFFABCDEF);
    YeknomToast.successBackgroundColor = defaultColor;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: YeknomToast.navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    YeknomToast.showSuccess('Default color');
    YeknomToast.showError(
      'Override color',
      backgroundColor: overrideColor,
      textColor: textColor,
    );
    await tester.pump();

    final defaultDecoration = tester.widget<DecoratedBox>(
      find.ancestor(
        of: find.text('Default color'),
        matching: find.byType(DecoratedBox),
      ),
    );
    final overrideDecoration = tester.widget<DecoratedBox>(
      find.ancestor(
        of: find.text('Override color'),
        matching: find.byType(DecoratedBox),
      ),
    );
    final overrideText = tester.widget<Text>(find.text('Override color'));

    expect((defaultDecoration.decoration as BoxDecoration).color, defaultColor);
    expect(
      (overrideDecoration.decoration as BoxDecoration).color,
      overrideColor,
    );
    expect(overrideText.style?.color, textColor);
  });

  testWidgets('stacks multiline notifications without overlap', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: YeknomToast.navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    YeknomToast.show(
      'First long message that wraps across several lines on a narrow screen',
    );
    YeknomToast.show(
      'Second long message that also wraps across several lines on a narrow screen',
    );
    await tester.pump();

    final firstRect = tester.getRect(find.textContaining('First long'));
    final secondRect = tester.getRect(find.textContaining('Second long'));

    expect(secondRect.top, greaterThan(firstRect.bottom));
  });

  testWidgets('moves remaining notifications up during exit', (tester) async {
    YeknomToast.displayDuration = const Duration(milliseconds: 500);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: YeknomToast.navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    YeknomToast.show('First');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    YeknomToast.show('Second');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final initialTop = tester.getTopLeft(find.text('Second')).dy;
    await tester.pump(const Duration(milliseconds: 125));
    final movingTop = tester.getTopLeft(find.text('Second')).dy;

    expect(movingTop, lessThan(initialTop));
    expect(find.text('First'), findsOneWidget);
  });

  testWidgets('Toast compatibility API shares configuration and overlay', (
    tester,
  ) async {
    const background = Color(0xFF284455);
    Toast.displayDuration = const Duration(seconds: 3);
    Toast.maxWidth = 320;
    Toast.defaultBackgroundColor = background;

    expect(YeknomToast.displayDuration, const Duration(seconds: 3));
    expect(YeknomToast.maxWidth, 320);
    expect(YeknomToast.defaultBackgroundColor, background);
    expect(Toast.navigatorKey, same(YeknomToast.navigatorKey));

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: Toast.navigatorKey,
        home: const Scaffold(body: SizedBox()),
      ),
    );

    Toast.show('Compatible');
    await tester.pump();

    expect(find.text('Compatible'), findsOneWidget);
  });
}
