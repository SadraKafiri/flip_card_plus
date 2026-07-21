import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flip_card_plus/flip_card_plus.dart';

void main() {
  // ── Smoke test ─────────────────────────────────────────────────────────

  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: FlipCardPlus(
        front: Container(
          key: const Key('front'),
          child: const Text('front'),
        ),
        back: Container(
          key: const Key('back'),
          child: const Text('back'),
        ),
      ),
    ));

    expect(find.byType(Text), findsNWidgets(2));
    await tester.tap(find.byType(Stack));
  });

  // ── Pointer blocking ───────────────────────────────────────────────────

  testWidgets('background interactions are ignored',
      (WidgetTester tester) async {
    bool backgroundTouched = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FlipCardPlus(
          front: const Text('front'),
          back: TextButton(
            onPressed: () => backgroundTouched = true,
            child: const Text('back'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    expect(backgroundTouched, false);
  });

  testWidgets('background enabled when turned back', (widgetTester) async {
    bool backgroundTouched = false;

    await widgetTester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FlipCardPlus(
          front: const Text('front'),
          back: TextButton(
            onPressed: () => backgroundTouched = true,
            child: const Text('back'),
          ),
        ),
      ),
    );

    await widgetTester.tap(find.byType(FlipCardPlus));
    await widgetTester.pumpAndSettle();

    final state = widgetTester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
    expect(state.currentSide, CardSide.back,
        reason: 'Ensure card flipped back');

    await widgetTester.tap(find.byType(TextButton));
    await widgetTester.pumpAndSettle();

    expect(backgroundTouched, true);
  });

  // ── Initial side ───────────────────────────────────────────────────────

  group('initial side with', () {
    testWidgets('front side', (widgetTester) async {
      await widgetTester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            initialSide: CardSide.front,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = widgetTester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      await widgetTester.tap(find.byType(FlipCardPlus));
      await widgetTester.pumpAndSettle();

      expect(state.currentSide, CardSide.back);
    });

    testWidgets('back side', (widgetTester) async {
      await widgetTester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            initialSide: CardSide.back,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = widgetTester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.back);

      await widgetTester.tap(find.byType(FlipCardPlus));
      await widgetTester.pumpAndSettle();

      expect(state.currentSide, CardSide.front);
    });
  });

  // ── Flip methods ───────────────────────────────────────────────────────

  group('cards flip', () {
    testWidgets('automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
            flipOnTouch: true,
          ),
        ),
      );
      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.back);
    });

    testWidgets('manually', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();
      expect(
        state.currentSide, CardSide.front,
        reason: 'Should not have turned by tapping',
      );

      final future = state.flip();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(
        state.currentSide, CardSide.back,
        reason: 'Should have turned by manually calling flip',
      );
    });

    testWidgets('manually via controller', (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final future = controller.flip();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(controller.state.currentSide, CardSide.back);
    });

    testWidgets('manually via controller without animation',
        (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      controller.flipWithoutAnimation();
      await tester.pump();

      expect(controller.state.currentSide, CardSide.back);
    });
  });

  // ── Skew & hint ────────────────────────────────────────────────────────

  group('skew', () {
    testWidgets('skew keeps isFront unchanged', (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      final future = controller.skew(0.2);
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front);
    });
  });

  group('hint', () {
    testWidgets('hint keeps isFront unchanged', (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      final future = controller.hint();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front);
    });
  });

  // ── FlipDirection & keepSameDirection ─────────────────────────────────

  group('FlipDirection & keepSameDirection', () {
    testWidgets('respects FlipDirection axis and multiplier',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            flipDirection: FlipDirection.horizontalRight,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final transition =
          tester.widget<FlipCardPlusTransition>(find.byType(FlipCardPlusTransition));
      expect(transition.flipDirection, FlipDirection.horizontalRight);

      final transitions = tester
          .widgetList<FlipPlusTransition>(find.byType(FlipPlusTransition))
          .toList();
      expect(transitions.length, 2);
      expect(transitions[0].multiplier, -1.0);
      expect(transitions[1].multiplier, -1.0);
      expect(transitions[0].direction, Axis.horizontal);
      expect(transitions[1].direction, Axis.horizontal);
    });

    testWidgets(
        'keepSameDirection continuously increases controller value during back-to-front flip',
        (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            keepSameDirection: true,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      // 1. Flip front → back
      final flip1 = controller.flip();
      await tester.pumpAndSettle();
      await flip1;
      expect(controller.state.currentSide, CardSide.back);
      expect(controller.state.controller.value, 1.0);

      // 2. Flip back → front
      final flip2 = controller.flip();
      await tester.pumpAndSettle();
      await flip2;
      expect(controller.state.currentSide, CardSide.front);
      expect(controller.state.controller.value, 2.0); // Continues to increase!
    });

    testWidgets('hides perpendicular elements when static',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final backOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('back'),
          matching: find.byType(Opacity),
        ),
      );
      expect(backOpacity.opacity, 0.0);

      final frontOpacityFinder = find.ancestor(
        of: find.text('front'),
        matching: find.byType(Opacity),
      );
      if (frontOpacityFinder.evaluate().isNotEmpty) {
        final frontOpacity = tester.widget<Opacity>(frontOpacityFinder);
        expect(frontOpacity.opacity, 1.0);
      }
    });
  });

  // ── Declarative side control ───────────────────────────────────────────

  group('declarative side control', () {
    testWidgets('initializes to the specified side', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            side: CardSide.back,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.back);
    });

    testWidgets('flips when side parameter changes', (WidgetTester tester) async {
      CardSide currentSide = CardSide.front;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  FlipCardPlus(
                    side: currentSide,
                    front: const Text('front'),
                    back: const Text('back'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentSide = currentSide.opposite;
                      });
                    },
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(state.currentSide, CardSide.back);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(state.currentSide, CardSide.front);
    });
  });

  // ── Deferred widget updates ────────────────────────────────────────────

  group('deferred widget updates', () {
    testWidgets('defers widget update until invisible', (WidgetTester tester) async {
      String frontText = 'Q1';
      String backText = 'A1';

      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  FlipCardPlus(
                    controller: controller,
                    front: Text(frontText),
                    back: Text(backText),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        frontText = 'Q2';
                        backText = 'A2';
                      });
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('Q1'), findsOneWidget);
      expect(find.text('A1'), findsOneWidget);

      final flip1 = controller.flip();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(TextButton));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Q1'), findsOneWidget);
      expect(find.text('Q2'), findsNothing);
      expect(find.text('A2'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Q2'), findsOneWidget);

      await tester.pumpAndSettle();
      await flip1;

      expect(find.text('Q2'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);
    });
  });

  // ── ListTile colour rendering ──────────────────────────────────────────

  group('ListTile color rendering', () {
    testWidgets('ListTile tile color does not render after flipping',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        // ignore: prefer_const_constructors
        MaterialApp(
          // ignore: prefer_const_constructors
          home: Scaffold(
            // ignore: prefer_const_constructors
            body: FlipCardPlus(
              // ignore: prefer_const_constructors
              front: ListTile(
                tileColor: Colors.red,
                title: const Text('front'),
              ),
              back: const Text('back'),
            ),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.back);

      final frontOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(ListTile),
          matching: find.byType(Opacity),
        ),
      );
      expect(frontOpacity.opacity, 0.0);
    });
  });

  // ── Matrix optimisation ────────────────────────────────────────────────

  group('matrix optimization', () {
    testWidgets('omits Transform widget when flat/static or perpendicular',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final transformWidgets = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(FlipPlusTransition),
          matching: find.byType(Transform),
        ),
      ).toList();

      expect(transformWidgets.isEmpty, true);
    });
  });

  // ── sizeToActiveSide ──────────────────────────────────────────────────

  group('sizeToActiveSide', () {
    testWidgets('respects sizeToActiveSide parameter', (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Center(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FlipCardPlus(
              controller: controller,
              sizeToActiveSide: true,
              front: const SizedBox(width: 100, height: 100),
              back: const SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(FlipCardPlus)), const Size(100, 100));

      final future = controller.flip();
      await tester.pumpAndSettle();
      await future;

      expect(tester.getSize(find.byType(FlipCardPlus)), const Size(200, 200));
    });
  });

  // ── Stack draw order ───────────────────────────────────────────────────

  group('Stack draw order', () {
    testWidgets('swaps children paint order at midpoint',
        (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            front: const Text('front', key: Key('front_key')),
            back: const Text('back', key: Key('back_key')),
          ),
        ),
      );

      List<Element> getStackChildren() {
        final stackElement = tester.element(find.byType(Stack));
        final children = <Element>[];
        stackElement.visitChildren(children.add);
        return children;
      }

      bool hasKey(Element parent, Key key) {
        bool found = false;
        void visit(Element element) {
          if (element.widget.key == key) found = true;
          element.visitChildren(visit);
        }
        visit(parent);
        return found;
      }

      // Initially: back at index 0, front at index 1 (on top)
      var children = getStackChildren();
      expect(children.length, 2);
      expect(hasKey(children[0], const Key('back_key')), true);
      expect(hasKey(children[1], const Key('front_key')), true);

      // At 25% (value <= 0.5): order unchanged
      final future = controller.flip();
      await tester.pump(const Duration(milliseconds: 100));

      children = getStackChildren();
      expect(hasKey(children[0], const Key('back_key')), true);
      expect(hasKey(children[1], const Key('front_key')), true);

      // At 75% (value > 0.5): order swaps — back child on top
      await tester.pump(const Duration(milliseconds: 300));

      children = getStackChildren();
      expect(hasKey(children[0], const Key('front_key')), true);
      expect(hasKey(children[1], const Key('back_key')), true);

      await tester.pumpAndSettle();
      await future;
    });
  });

  // ── isDisabled ─────────────────────────────────────────────────────────

  group('isDisabled', () {
    testWidgets('prevents flip on tap when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            isDisabled: true,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      // Card must not have flipped
      expect(state.currentSide, CardSide.front);
    });

    testWidgets('prevents flip via controller when disabled',
        (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            isDisabled: true,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      // controller.flip() must respect isDisabled and return immediately
      await controller.flip();
      await tester.pumpAndSettle();

      expect(controller.state.currentSide, CardSide.front);
    });

    testWidgets('prevents flipWithoutAnimation when disabled',
        (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            isDisabled: true,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      controller.flipWithoutAnimation();
      await tester.pump();

      expect(controller.state.currentSide, CardSide.front);
    });
  });

  // ── onFlipStart ────────────────────────────────────────────────────────

  group('onFlipStart', () {
    testWidgets('fires with correct from/to sides on tap',
        (WidgetTester tester) async {
      CardSide? capturedFrom;
      CardSide? capturedTo;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            onFlipStart: (from, to) {
              capturedFrom = from;
              capturedTo = to;
            },
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      expect(capturedFrom, CardSide.front);
      expect(capturedTo, CardSide.back);
    });

    testWidgets('fires with reversed sides on second tap',
        (WidgetTester tester) async {
      CardSide? capturedFrom;
      CardSide? capturedTo;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            onFlipStart: (from, to) {
              capturedFrom = from;
              capturedTo = to;
            },
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      // First flip: front → back
      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      // Second flip: back → front
      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();

      expect(capturedFrom, CardSide.back);
      expect(capturedTo, CardSide.front);
    });
  });

  // ── flipCount ─────────────────────────────────────────────────────────

  group('flipCount', () {
    testWidgets('increments on each flip', (WidgetTester tester) async {
      final controller = FlipCardPlusController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            controller: controller,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.flipCount, 0);

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();
      expect(state.flipCount, 1);

      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();
      expect(state.flipCount, 2);

      // Controller flip also counts
      final f = controller.flip();
      await tester.pumpAndSettle();
      await f;
      expect(state.flipCount, 3);

      // flipWithoutAnimation also counts
      controller.flipWithoutAnimation();
      await tester.pump();
      expect(state.flipCount, 4);
    });

    testWidgets('does not increment when isDisabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            isDisabled: true,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      await tester.tap(find.byType(FlipCardPlus));
      await tester.pumpAndSettle();
      expect(state.flipCount, 0);
    });
  });

  // ── borderRadius ──────────────────────────────────────────────────────

  group('borderRadius', () {
    testWidgets('applies ClipRRect to each face', (WidgetTester tester) async {
      const radius = BorderRadius.all(Radius.circular(16));

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            borderRadius: radius,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      // There should be two ClipRRect widgets (one per face)
      final clips = tester
          .widgetList<ClipRRect>(find.byType(ClipRRect))
          .toList();
      expect(clips.length, 2);
      for (final clip in clips) {
        expect(clip.borderRadius, radius);
      }
    });

    testWidgets('no ClipRRect without borderRadius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsNothing);
    });
  });

  // ── curve ─────────────────────────────────────────────────────────────

  group('curve', () {
    testWidgets('custom curve is passed to FlipCardPlusTransition',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            curve: Curves.elasticOut,
            reverseCurve: Curves.bounceIn,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final transition =
          tester.widget<FlipCardPlusTransition>(find.byType(FlipCardPlusTransition));
      expect(transition.curve, Curves.elasticOut);
      expect(transition.reverseCurve, Curves.bounceIn);
    });
  });

  // ── semanticLabel ──────────────────────────────────────────────────────

  group('semanticLabel', () {
    testWidgets('Semantics widget is present when label is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            semanticLabel: 'Product card',
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final labeled = semantics
          .where((s) => s.properties.label == 'Product card')
          .toList();
      expect(labeled.isNotEmpty, true);
    });

    testWidgets('no Semantics widget without label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final semanticsWithLabel = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.label != null && s.properties.label!.isNotEmpty)
          .toList();
      expect(semanticsWithLabel.isEmpty, true);
    });
  });

  // ── Drag-to-flip ───────────────────────────────────────────────────────

  group('drag to flip', () {
    // Helper: build a 300×300 FlipCardPlus with a real render size
    Future<FlipCardPlusState> buildDragCard(
      WidgetTester tester, {
      bool disabled = false,
    }) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlipCardPlus(
                  flipOnDrag: true,
                  flipOnTouch: false,
                  isDisabled: disabled,
                  front: const Text('front'),
                  back: const Text('back'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
    }

    testWidgets('drag past threshold flips the card',
        (WidgetTester tester) async {
      final state = await buildDragCard(tester);
      expect(state.currentSide, CardSide.front);

      // Simulate drag: start in card center, move 170px left (57% of 300px)
      final center = tester.getCenter(find.byType(FlipCardPlus));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      // Move in steps to accumulate realistic velocity
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-17, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.back,
          reason: 'Card should snap to back after drag past 50% threshold');
    });

    testWidgets('drag below threshold snaps card back',
        (WidgetTester tester) async {
      final state = await buildDragCard(tester);

      // Drag only 80px left (27% of 300px) then lift slowly (low velocity)
      final center = tester.getCenter(find.byType(FlipCardPlus));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      // Move in small steps, then pause to bleed off velocity
      for (int i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(-16, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      // Pause 200ms so velocity decays
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front,
          reason: 'Card should snap back below threshold with low velocity');
    });

    testWidgets('drag disabled when isDisabled is true',
        (WidgetTester tester) async {
      final state = await buildDragCard(tester, disabled: true);

      final center = tester.getCenter(find.byType(FlipCardPlus));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-20, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front,
          reason: 'Disabled card must not flip on drag');
    });
  });

  // ── flipOnHover ─────────────────────────────────────────────────────────

  group('flipOnHover', () {
    testWidgets('hovering over card flips to back, exiting flips to front', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            flipOnHover: true,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      // Hover enter
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await tester.pump();
      
      final center = tester.getCenter(find.byType(FlipCardPlus));
      await gesture.moveTo(center);
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.back,
          reason: 'Hovering over card should trigger flip to back');

      // Hover exit
      await gesture.moveTo(Offset.infinite);
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front,
          reason: 'Exiting hover should trigger flip to front');
    });
  });

  // ── perspective ──────────────────────────────────────────────────────────

  group('perspective', () {
    testWidgets('custom perspective propagates to FlipPlusTransition', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            perspective: 0.005,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final transition = tester.widget<FlipCardPlusTransition>(find.byType(FlipCardPlusTransition));
      expect(transition.perspective, 0.005);
    });
  });

  // ── elevation & shadowColor ──────────────────────────────────────────────

  group('elevation and shadowColor', () {
    testWidgets('dynamic shadow is rendered with elevation > 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            elevation: 8.0,
            shadowColor: Colors.red,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final decoratedBoxFinder = find.byType(DecoratedBox);
      expect(decoratedBoxFinder, findsWidgets);

      final decoratedBox = tester.widgetList<DecoratedBox>(decoratedBoxFinder).first;
      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      
      final shadow = decoration.boxShadow!.first;
      expect(shadow.color.withAlpha(255), Colors.red.withAlpha(255));
      // At start of animation, progress = 0.0, currentElevation = 8.0, blurRadius = 16.0
      expect(shadow.blurRadius, 16.0);
    });
  });

  // ── rtlAware ─────────────────────────────────────────────────────────────

  group('rtlAware text direction', () {
    testWidgets('reverses multiplier in RTL layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: FlipCardPlus(
            rtlAware: true,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      // In LTR, multiplier is 1.0. In RTL with rtlAware, it should be -1.0
      expect(state.effectiveFlipMultiplier, -1.0);
    });

    testWidgets('does not reverse multiplier in RTL layout if rtlAware is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: FlipCardPlus(
            rtlAware: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.effectiveFlipMultiplier, 1.0);
    });
  });

  // ── keyboard focus and triggers ─────────────────────────────────────────

  group('keyboard focus and triggers', () {
    testWidgets('focused card flips on Space and Enter keys', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: FlipCardPlus(
                front: Text('front'),
                back: Text('back'),
              ),
            ),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      // Focus the card
      final focusNodeOfWidget = Focus.of(tester.element(find.text('front')));
      focusNodeOfWidget.requestFocus();
      await tester.pump();

      // Press Space
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(state.currentSide, CardSide.back,
          reason: 'Pressing Space key on focused card should trigger flip');

      // Press Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(state.currentSide, CardSide.front,
          reason: 'Pressing Enter key on focused card should trigger flip back');
    });
  });

  // ── auto-flip timer ──────────────────────────────────────────────────────

  group('auto-flip timer', () {
    testWidgets('timer is cancelled on dispose', (WidgetTester tester) async {
      bool showCard = true;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: showCard
                   ? const FlipCardPlus(
                       autoFlipDuration: Duration(milliseconds: 100),
                       front: Text('front'),
                       back: Text('back'),
                     )
                   : const SizedBox(),
            );
          },
        ),
      );

      expect(find.byType(FlipCardPlus), findsOneWidget);

      // Dispose the widget
      showCard = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: showCard
                   ? const FlipCardPlus(
                       autoFlipDuration: Duration(milliseconds: 100),
                       front: Text('front'),
                       back: Text('back'),
                     )
                   : const SizedBox(),
            );
          },
        ),
      );

      expect(find.byType(FlipCardPlus), findsNothing);

      // Wait for timer
      await tester.pump(const Duration(milliseconds: 150));
      expect(true, true);
    });
  });

  // ── focusable: false ─────────────────────────────────────────────────────

  group('focusable: false', () {
    testWidgets('does not wrap in Focus widget when focusable is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            focusable: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final focusWidgetFinder = find.descendant(
        of: find.byType(FlipCardPlus),
        matching: find.byType(Focus),
      );
      expect(focusWidgetFinder, findsNothing);
    });
  });

  // ── drag threshold extremes ──────────────────────────────────────────────

  group('drag threshold extremes', () {
    Future<FlipCardPlusState> buildThresholdCard(
      WidgetTester tester,
      double threshold,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: FlipCardPlus(
                  flipOnDrag: true,
                  flipOnTouch: false,
                  dragThreshold: threshold,
                  front: const Text('front'),
                  back: const Text('back'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
    }

    testWidgets('dragThreshold: 0.1 commits flip early', (WidgetTester tester) async {
      final state = await buildThresholdCard(tester, 0.1);

      // Drag 40px left (13% of 300px, which is > 10% threshold)
      final center = tester.getCenter(find.byType(FlipCardPlus));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(-8, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200)); // Bleed velocity
      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.back,
          reason: 'Should commit flip because drag (13%) is above threshold (10%)');
    });

    testWidgets('dragThreshold: 0.9 reverts flip late', (WidgetTester tester) async {
      final state = await buildThresholdCard(tester, 0.9);

      // Drag 240px left (80% of 300px, which is < 90% threshold)
      final center = tester.getCenter(find.byType(FlipCardPlus));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      for (int i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(-24, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200)); // Bleed velocity
      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.currentSide, CardSide.front,
          reason: 'Should snap back because drag (80%) is below threshold (90%)');
    });
  });

  // ── succession of rapid flip calls ──────────────────────────────────────

  group('succession of rapid flip calls', () {
    testWidgets('multiple fast flip calls do not crash or throw', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardPlusState>(find.byType(FlipCardPlus));
      expect(state.currentSide, CardSide.front);

      // Call flip three times in the same frame
      state.flip();
      state.flip();
      state.flip();
      await tester.pumpAndSettle();

      // Should complete on one side and remain completely stable
      expect(state.controller.status, isNotNull);
    });
  });

  // ── useRepaintBoundary ───────────────────────────────────────────────────

  group('useRepaintBoundary', () {
    testWidgets('renders RepaintBoundary when true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            useRepaintBoundary: true,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final repaintBoundaries = find.descendant(
        of: find.byType(FlipCardPlus),
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaries, findsNWidgets(2)); // Front & Back faces each get one
    });

    testWidgets('does not render RepaintBoundary when false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            useRepaintBoundary: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final repaintBoundaries = find.descendant(
        of: find.byType(FlipCardPlus),
        matching: find.byType(RepaintBoundary),
      );
      expect(repaintBoundaries, findsNothing);
    });
  });

  // ── clipBehavior ─────────────────────────────────────────────────────────

  group('clipBehavior', () {
    testWidgets('applies custom clipBehavior to ClipRRect', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCardPlus(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            clipBehavior: Clip.hardEdge,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsNWidgets(2));

      final clipRRect = tester.widgetList<ClipRRect>(clipRRectFinder).first;
      expect(clipRRect.clipBehavior, Clip.hardEdge);
    });
  });
}


