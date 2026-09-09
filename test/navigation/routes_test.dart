import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Back swipe dismiss interrupted by route push', (tester) async {
    await tester.pumpWidget(
      GetCupertinoApp(
        popGesture: true,
        defaultTransition: Transition.cupertino,
        home: CupertinoPageScaffold(
          child: Center(
            child: CupertinoButton(
              onPressed: () {
                Get.to(
                  () => const CupertinoPageScaffold(
                    child: Center(child: Text('route')),
                  ),
                );
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
    await gesture.moveBy(const Offset(400, 0));
    await tester.pump();

    final routeScaffold = find.ancestor(
      of: find.text('route'),
      matching: find.byType(CupertinoPageScaffold),
    );
    expect(
      tester.getTopLeft(routeScaffold).dx,
      moreOrLessEquals(400, epsilon: 1),
    );
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

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('route'), findsOneWidget);
    expect(find.text('push'), findsNothing);

    gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(400, 0));
    await tester.pump();

    final dismissingRouteScaffold = find.ancestor(
      of: find.text('route'),
      matching: find.byType(CupertinoPageScaffold),
    );
    expect(
      tester.getTopLeft(dismissingRouteScaffold).dx,
      moreOrLessEquals(400, epsilon: 1),
    );
    expect(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .userGestureInProgress,
      true,
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 210));

    Get.to(
      () => const CupertinoPageScaffold(child: Center(child: Text('route'))),
    );

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
