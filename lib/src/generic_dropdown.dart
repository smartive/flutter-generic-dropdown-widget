import 'package:flutter/material.dart';

import './generic_dropdown_config_provider.dart';

/// TODO
enum DropdownAnchor {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// TODO
enum DropdownDirection {
  upLeft,
  upRight,
  downLeft,
  downRight,
}

/// TODO
class GenericDropdown extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback repaint, VoidCallback close) contentBuilder;

  final DropdownAnchor anchor;
  final DropdownDirection direction;

  /// The widget that will be used to toggle the dropdown.
  /// Be aware that if the widget you return captures mouse events,
  /// you need to ensure that the mouse events are passed to the dropdown.
  final Widget Function(BuildContext context, bool isOpen) toggleBuilder;

  /// Additional offset to the dropdown position.
  final Offset? offset;

  const GenericDropdown(
      {super.key,
      required this.contentBuilder,
      this.anchor = DropdownAnchor.bottomLeft,
      this.direction = DropdownDirection.downRight,
      required this.toggleBuilder,
      this.offset});

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
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0);
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0);
      left = togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0);
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.topLeft && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0);
      left = togglePosition.dx + (widget.offset?.dx ?? 0);
    }

    // Anchor TOP RIGHT
    if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0);
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0) - size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0);
      left = togglePosition.dx + (widget.offset?.dx ?? 0) + size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0);
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0) - size.width;
    } else if (widget.anchor == DropdownAnchor.topRight && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0);
      left = togglePosition.dx + (widget.offset?.dx ?? 0) + size.width;
    }

    // Anchor BOTTOM LEFT
    if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0) - size.height;
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0) - size.height;
      left = togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0) + size.height;
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0);
    } else if (widget.anchor == DropdownAnchor.bottomLeft && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0) + size.height;
      left = togglePosition.dx + (widget.offset?.dx ?? 0);
    }

    // Anchor BOTTOM RIGHT
    if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.upLeft) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0) - size.height;
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0) - size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.upRight) {
      bottom = screenSize.height - togglePosition.dy + (widget.offset?.dy ?? 0) - size.height;
      left = togglePosition.dx + (widget.offset?.dx ?? 0) + size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.downLeft) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0) + size.height;
      right = screenSize.width - togglePosition.dx + (widget.offset?.dx ?? 0) - size.width;
    } else if (widget.anchor == DropdownAnchor.bottomRight && widget.direction == DropdownDirection.downRight) {
      top = togglePosition.dy + (widget.offset?.dy ?? 0) + size.height;
      left = togglePosition.dx + (widget.offset?.dx ?? 0) + size.width;
    }

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _close,
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
                  child: StatefulBuilder(
                      builder: (context, setState) =>
                          widget.contentBuilder.call(context, () => setState(() {}), _close)),
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
