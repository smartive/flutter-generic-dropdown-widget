import 'package:flutter/material.dart';

import './generic_dropdown_config_provider.dart';

/// Determines the anchor of the dropdown. The
/// anchor is relative to the toggle and is used
/// to place the content when showing the dropdown.
enum DropdownAnchor {
  /// The top left corner of the
  /// toggle is used as anchor.
  topLeft,

  /// The top right corner of the
  /// toggle is used as anchor.
  topRight,

  /// The bottom left corner of the
  /// toggle is used as anchor.
  bottomLeft,

  /// The bottom right corner of the
  /// toggle is used as anchor.
  bottomRight,
}

/// Determines the direction of the content.
/// In combination with the [DropdownAnchor],
/// the dropdown will be positioned relative to the toggle.
enum DropdownDirection {
  /// The content will be positioned with the bottom
  /// right edge to the [DropdownAnchor] and opens to the top left.
  upLeft,

  /// The content will be positioned with the bottom
  /// left edge to the [DropdownAnchor] and opens to the top right.
  upRight,

  /// The content will be positioned with the top
  /// right edge to the [DropdownAnchor] and opens to the bottom left.
  downLeft,

  /// The content will be positioned with the top
  /// left edge to the [DropdownAnchor] and opens to the bottom right.
  downRight,
}

typedef ContentBuilder = Widget Function(BuildContext context, VoidCallback repaint, VoidCallback close);
typedef ToggleBuilder = Widget Function(BuildContext context, bool isOpen);

/// A generic dropdown widget that enables arbitrary content
/// with an arbitrary toggle widget. The content can be placed
/// relative to the toggle in any direction with the
/// [anchor] and [direction] configuration.
///
/// The offset enables additional possitioning options for the
/// content. The [contentBuilder] receives a "repaint" and a
/// "close" callbacks, which can help updating the content
/// or closing the content entirely.
class GenericDropdown extends StatefulWidget {
  /// A builder for the content of the dropdown. Creates the
  /// content of the dropdown.
  ///
  /// This builder inserts two callbacks to the child that can be called from content
  /// components: [repaint] and [close]. The [repaint] will trigger a "setState" in the
  /// content and should repaint the content (to update objects inside the content), while
  /// [close] will close the dropdown.
  final ContentBuilder contentBuilder;

  /// The anchor of the dropdown. Defines
  /// on which point of the toggle the content
  /// will be anchored. Defaults to [DropdownAnchor.bottomLeft].
  final DropdownAnchor anchor;

  /// The direction of the content. Defines
  /// how the content will be "opened".
  /// Defaults to [DropdownDirection.downRight].
  final DropdownDirection direction;

  /// The widget that will be used to toggle the dropdown.
  /// Receives a boolean value (`isOpen`) that indicates if the content
  /// is shown or not.
  /// Be aware that if the widget you return captures mouse events,
  /// you need to ensure that the mouse events are passed to the dropdown.
  final ToggleBuilder toggleBuilder;

  /// Additional offset to the dropdown position.
  /// The offset is calculated in the direction of the
  /// [DropdownDirection]. Defaults to [Offset.zero].
  final Offset offset;

  /// Whether the content should close if any click/tap happens
  /// outside the content container. Defaults to `true`.
  final bool closeOnOutsideTap;

  /// Whether the content (dropdown) should be opened on render.
  /// Defaults to `false`.
  final bool openOnRender;

  const GenericDropdown(
      {super.key,
      required this.contentBuilder,
      this.anchor = DropdownAnchor.bottomLeft,
      this.direction = DropdownDirection.downRight,
      required this.toggleBuilder,
      this.closeOnOutsideTap = true,
      this.openOnRender = false,
      this.offset = Offset.zero});

  @override
  State<GenericDropdown> createState() => _GenericDropdownState();
}

class _GenericDropdownState extends State<GenericDropdown> {
  var _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  void initState() {
    if (widget.openOnRender) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open(context));
    }
    super.initState();
  }

  RenderBox? _ancestor(BuildContext context) =>
      GenericDropdownConfigProvider.of(context)?.rootScreenKey?.currentContext?.findRenderObject() as RenderBox?;

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _open(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;

    final size = renderBox.size;
    final togglePosition = renderBox.localToGlobal(Offset.zero, ancestor: _ancestor(context));

    final screenSize = _screenSize(context);

    /*
    * top -> calculated when downLeft or downRight
    * bottom -> calculated when upLeft or upRight
    * left -> calculated when upRight or downRight
    * right -> calculated when upLeft or downLeft
    *
    * if the anchor is top and direction is up (bottom is calculated), we need to add the height of the toggle.
    * if the anchor is left and direction is left (right is calculated), we need to add the width of the toggle.
    * if the anchor is bottom and direction is down (top is calculated), we need to add the height of the toggle.
    * if the anchor is right and direction is right (left is calculated), we need to add the width of the toggle.
    *
    * for bottom and right, the relative position of the toggle compared to the screen must be taken into account.
    * bottom -> screen height - toggle position and right -> screen width - toggle position.
    *
    * All calculations are done manually (with 16 ifs) so the cases are clear and the code is not
    * too complicated or clever.
    */
    double? top, left, bottom, right;

    // Anchor TOP LEFT
    if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
      right = screenSize.width - togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
      left = togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + widget.offset.dy;
      right = screenSize.width - togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + widget.offset.dy;
      left = togglePosition.dx + widget.offset.dx;
    }

    // Anchor TOP RIGHT
    if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
      right = screenSize.width - togglePosition.dx + widget.offset.dx - size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
      left = togglePosition.dx + widget.offset.dx + size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + widget.offset.dy;
      right = screenSize.width - togglePosition.dx + widget.offset.dx - size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + widget.offset.dy;
      left = togglePosition.dx + widget.offset.dx + size.width;
    }

    // Anchor BOTTOM LEFT
    if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy - size.height;
      right = screenSize.width - togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy - size.height;
      left = togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + widget.offset.dy + size.height;
      right = screenSize.width - togglePosition.dx + widget.offset.dx;
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + widget.offset.dy + size.height;
      left = togglePosition.dx + widget.offset.dx;
    }

    // Anchor BOTTOM RIGHT
    if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy - size.height;
      right = screenSize.width - togglePosition.dx + widget.offset.dx - size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + widget.offset.dy - size.height;
      left = togglePosition.dx + widget.offset.dx + size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + widget.offset.dy + size.height;
      right = screenSize.width - togglePosition.dx + widget.offset.dx - size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + widget.offset.dy + size.height;
      left = togglePosition.dx + widget.offset.dx + size.width;
    }

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => widget.closeOnOutsideTap ? _close() : null,
          child: Container(
            alignment: Alignment.topLeft,
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: top,
                  left: left,
                  bottom: bottom,
                  right: right,
                  child: GestureDetector(
                    onTap: () {
                      // this gesture detector prevents
                      // the bubbling event that closes the
                      // content on a click inside the
                      // content.
                    },
                    child: StatefulBuilder(
                        builder: (context, setState) =>
                            widget.contentBuilder.call(context, () => setState(() {}), _close)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() => _isOpen = true);
  }

  Size _screenSize(BuildContext context) => _ancestor(context)?.size ?? MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => _isOpen ? _close() : _open(context),
                  child: widget.toggleBuilder(context, _isOpen),
                ),
              ),
            ],
          ),
        ],
      );
}
