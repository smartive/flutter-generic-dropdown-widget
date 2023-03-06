# Generic Dropdown Widget

The generic dropdown Flutter widget is a customizable component
that allows users to toggle between two states: a closed state and
an open state, revealing content. This widget is designed to support arbitrary
toggle and content widgets. Developers can define their own widgets to be used
as the toggle button and the content within the dropdown.

Head over to the [storybook](https://smartive.github.io/flutter-generic-dropdown-widget/)
to see it in action. (Much love to
(storybook_flutter)[https://github.com/ookami-kb/storybook_flutter] at this point!)

## Usage

Import the package and then use the `GenericDropdown` widget.
The widget itself is well documented, so there is not much
need of explaining it here. The following example shows how
to use the dropdown with two simple containers:

```dart
// imports and stuff.

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GenericDropdown(
      toggleBuilder: (context, isOpen) => Container(
        height: 50,
        width: 50,
        color: isOpen ? Colors.green : Colors.red,
      ),
      contentBuilder: (context, repaint, close) => Container(
        height: 100,
        width: 100,
        color: Colors.blue,
      ),
    );
}
```

A note about the `GenericDropdownConfigProvider`:
If the root renderbox of the dropdown is not the
original root (e.g. if the dropdown is inside a `Storybook`),
you need to provide a `GlobalKey` with the root screen
render box reference. Otherwise, the position of the
content will be calculated incorrectly.
