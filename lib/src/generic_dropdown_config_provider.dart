import 'package:flutter/widgets.dart';

/// Config provider for the [GenericDropdown] widget.
/// Allows overwriting the screen that determines the
/// position of the dropdown overlay. Normally, this is not
/// required but may be used in situations where the dropdown
/// is positioned inside another "parent" widget.
///
/// As an example, this technique is required when displaying
/// the dropdown in storybook. Storybook wraps all stories inside
/// their own MaterialApp and thus the dropdown overlay would render
/// at the wrong position. With this config, the dropdown can
/// utilize the root storybook as root screen key to calculate
/// the position of the content.
class GenericDropdownConfigProvider extends InheritedWidget {
  /// The key of the root screen that contains the dropdown.
  /// The screen is used to calculate the relative position
  /// of the content overlay to the toggle.
  final GlobalKey? rootScreenKey;

  const GenericDropdownConfigProvider({super.key, this.rootScreenKey, required super.child});

  @override
  bool updateShouldNotify(GenericDropdownConfigProvider oldWidget) => rootScreenKey != oldWidget.rootScreenKey;

  static GenericDropdownConfigProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GenericDropdownConfigProvider>();
}
