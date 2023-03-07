import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generic_dropdown_widget/src/generic_dropdown.dart';

Widget _wrapper(Widget child) => MaterialApp(home: Scaffold(body: SafeArea(child: Center(child: child))));

class _PlacementCase {
  final DropdownAnchor anchor;
  final DropdownDirection direction;
  final List<List<int>> translation;

  Offset topLeft(Rect toggle, Rect content) =>
      _anchor(toggle).translate(content.width * translation[0][0], content.height * translation[0][1]);
  Offset topRight(Rect toggle, Rect content) =>
      _anchor(toggle).translate(content.width * translation[1][0], content.height * translation[1][1]);
  Offset bottomLeft(Rect toggle, Rect content) =>
      _anchor(toggle).translate(content.width * translation[2][0], content.height * translation[2][1]);
  Offset bottomRight(Rect toggle, Rect content) =>
      _anchor(toggle).translate(content.width * translation[3][0], content.height * translation[3][1]);

  Offset _anchor(Rect toggle) {
    switch (anchor) {
      case DropdownAnchor.topLeft:
        return toggle.topLeft;
      case DropdownAnchor.topRight:
        return toggle.topRight;
      case DropdownAnchor.bottomLeft:
        return toggle.bottomLeft;
      case DropdownAnchor.bottomRight:
        return toggle.bottomRight;
    }
  }

  const _PlacementCase(
    this.anchor,
    this.direction, {
    required this.translation,
  });
}

void main() {
  group('GenericDropdown -', () {
    testWidgets('should render the toggle.', (tester) async {
      const toggleKey = Key('toggle');
      await tester.pumpWidget(_wrapper(GenericDropdown(
        toggleBuilder: (_, __) => Container(
          key: toggleKey,
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        contentBuilder: (_, __, ___) => Container(),
      )));

      expect(find.byKey(toggleKey), findsOneWidget);
    });

    testWidgets('should re-render the toggle on open.', (tester) async {
      const closeKey = Key('toggleClose');
      const openKey = Key('toggleOpen');

      await tester.pumpWidget(_wrapper(GenericDropdown(
        toggleBuilder: (_, isOpen) => Container(
          key: isOpen ? openKey : closeKey,
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        contentBuilder: (_, __, ___) => Container(),
      )));

      expect(find.byKey(closeKey), findsOneWidget);
      expect(find.byKey(openKey), findsNothing);

      await tester.tap(find.byKey(closeKey));
      await tester.pumpAndSettle();

      expect(find.byKey(closeKey), findsNothing);
      expect(find.byKey(openKey), findsOneWidget);
    });

    testWidgets('should render the content when opened.', (tester) async {
      const toggleKey = Key('toggle');
      const contentKey = Key('content');

      await tester.pumpWidget(_wrapper(GenericDropdown(
        toggleBuilder: (_, isOpen) => Container(
          key: toggleKey,
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        contentBuilder: (_, __, ___) => Container(
          key: contentKey,
          height: 50,
          width: 200,
          color: Colors.blue,
        ),
      )));

      await tester.tap(find.byKey(toggleKey));
      await tester.pumpAndSettle();

      expect(find.byKey(toggleKey), findsOneWidget);
      expect(find.byKey(contentKey), findsOneWidget);
    });

    testWidgets('should hide the content when closed.', (tester) async {
      const toggleKey = Key('toggle');
      const contentKey = Key('content');

      await tester.pumpWidget(_wrapper(GenericDropdown(
        toggleBuilder: (_, isOpen) => Container(
          key: toggleKey,
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        contentBuilder: (_, __, ___) => Container(
          key: contentKey,
          height: 50,
          width: 200,
          color: Colors.blue,
        ),
      )));

      await tester.tap(find.byKey(toggleKey));
      await tester.pumpAndSettle();

      expect(find.byKey(toggleKey), findsOneWidget);
      expect(find.byKey(contentKey), findsOneWidget);

      await tester.tap(find.byKey(toggleKey));
      await tester.pumpAndSettle();

      expect(find.byKey(toggleKey), findsOneWidget);
      expect(find.byKey(contentKey), findsNothing);
    });

    testWidgets('should render content when "openOnRender" is "true".', (tester) async {
      const toggleKey = Key('toggle');
      const contentKey = Key('content');

      await tester.pumpWidget(_wrapper(GenericDropdown(
        openOnRender: true,
        toggleBuilder: (_, isOpen) => Container(
          key: toggleKey,
          height: 100,
          width: 100,
          color: Colors.red,
        ),
        contentBuilder: (_, __, ___) => Container(
          key: contentKey,
          height: 50,
          width: 200,
          color: Colors.blue,
        ),
      )));
      await tester.pumpAndSettle();

      expect(find.byKey(toggleKey), findsOneWidget);
      expect(find.byKey(contentKey), findsOneWidget);
    });

    group('Content Placement -', () {
      final placementCases = [
        const _PlacementCase(
          DropdownAnchor.topLeft,
          DropdownDirection.upLeft,
          translation: [
            [-1, -1],
            [0, -1],
            [-1, 0],
            [0, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topLeft,
          DropdownDirection.upRight,
          translation: [
            [0, -1],
            [1, -1],
            [0, 0],
            [1, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topLeft,
          DropdownDirection.downLeft,
          translation: [
            [-1, 0],
            [0, 0],
            [-1, 1],
            [0, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topLeft,
          DropdownDirection.downRight,
          translation: [
            [0, 0],
            [1, 0],
            [0, 1],
            [1, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topRight,
          DropdownDirection.upLeft,
          translation: [
            [-1, -1],
            [0, -1],
            [-1, 0],
            [0, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topRight,
          DropdownDirection.upRight,
          translation: [
            [0, -1],
            [1, -1],
            [0, 0],
            [1, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topRight,
          DropdownDirection.downLeft,
          translation: [
            [-1, 0],
            [0, 0],
            [-1, 1],
            [0, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.topRight,
          DropdownDirection.downRight,
          translation: [
            [0, 0],
            [1, 0],
            [0, 1],
            [1, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomLeft,
          DropdownDirection.upLeft,
          translation: [
            [-1, -1],
            [0, -1],
            [-1, 0],
            [0, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomLeft,
          DropdownDirection.upRight,
          translation: [
            [0, -1],
            [1, -1],
            [0, 0],
            [1, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomLeft,
          DropdownDirection.downLeft,
          translation: [
            [-1, 0],
            [0, 0],
            [-1, 1],
            [0, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomLeft,
          DropdownDirection.downRight,
          translation: [
            [0, 0],
            [1, 0],
            [0, 1],
            [1, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomRight,
          DropdownDirection.upLeft,
          translation: [
            [-1, -1],
            [0, -1],
            [-1, 0],
            [0, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomRight,
          DropdownDirection.upRight,
          translation: [
            [0, -1],
            [1, -1],
            [0, 0],
            [1, 0],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomRight,
          DropdownDirection.downLeft,
          translation: [
            [-1, 0],
            [0, 0],
            [-1, 1],
            [0, 1],
          ],
        ),
        const _PlacementCase(
          DropdownAnchor.bottomRight,
          DropdownDirection.downRight,
          translation: [
            [0, 0],
            [1, 0],
            [0, 1],
            [1, 1],
          ],
        ),
      ];

      for (final testCase in placementCases) {
        testWidgets(
            'should place content at the correct position (anchor: ${testCase.anchor.name}, direction: ${testCase.direction.name}).',
            (tester) async {
          const toggleKey = Key('toggle');
          const contentKey = Key('content');

          await tester.pumpWidget(_wrapper(GenericDropdown(
            anchor: testCase.anchor,
            direction: testCase.direction,
            openOnRender: true,
            toggleBuilder: (_, isOpen) => Container(
              key: toggleKey,
              height: 100,
              width: 100,
              color: Colors.red,
            ),
            contentBuilder: (_, __, ___) => Container(
              key: contentKey,
              height: 50,
              width: 200,
              color: Colors.blue,
            ),
          )));
          await tester.pumpAndSettle();

          final toggleRect = tester.getRect(find.byKey(toggleKey));
          final contentRect = tester.getRect(find.byKey(contentKey));

          expect(contentRect.topLeft, testCase.topLeft(toggleRect, contentRect), reason: 'topLeft mismatch');
          expect(contentRect.topRight, testCase.topRight(toggleRect, contentRect), reason: 'topRight mismatch');
          expect(contentRect.bottomLeft, testCase.bottomLeft(toggleRect, contentRect), reason: 'bottomLeft mismatch');
          expect(contentRect.bottomRight, testCase.bottomRight(toggleRect, contentRect),
              reason: 'bottomRight mismatch');
        });
      }
    });
  });
}
