import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Back swipe dismiss interrupted by route push', (tester) async {
    await tester.pumpWidget(
      GetCupertinoApp(
        popGesture: true,
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoButton(
              onPressed: () {
                Get.to(() => const CupertinoPageScaffold(
                      child: Center(child: Text('route')),
                    ));
              },
              child: const Text('push'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('route'), findsOneWidget);
    expect(find.text('push'), findsNothing);

    var gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(600, 0));
    await tester.pump();

    expect(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .userGestureInProgress,
      true,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('push'), findsOneWidget);
    expect(find.text('route'), findsNothing);
    expect(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .userGestureInProgress,
      false,
    );

    // Start another interactive pop and push a new route while the route is
    // completing its dismiss animation. Flutter 3.47 changed the exact
    // Cupertino transition geometry, so this test validates navigator state
    // instead of internal pixel offsets.
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('route'), findsOneWidget);
    expect(find.text('push'), findsNothing);

    gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(600, 0));
    await tester.pump();
    expect(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .userGestureInProgress,
      true,
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    Get.to(() => const CupertinoPageScaffold(
          child: Center(child: Text('route')),
        ));

    await tester.pumpAndSettle();
    expect(find.text('route'), findsOneWidget);
    expect(find.text('push'), findsNothing);
    expect(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .userGestureInProgress,
      false,
    );
  });
}
