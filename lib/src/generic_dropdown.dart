import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './generic_dropdown_config_provider.dart';

typedef ContentBuilder = Widget Function(
    BuildContext context, VoidCallback repaint, VoidCallback close);

typedef ToggleBuilder = Widget Function(BuildContext context, bool isOpen);

/// Determines the anchor of the dropdown. The
/// anchor is relative to the toggle and is used
/// to place the content when showing the dropdown.
enum DropdownAnchor {
  /// The top left corner of the
  /// toggle is used as anchor.
  topLeft,

  /// The center top of the
  /// toggle is used as anchor.
  topCenter,

  /// The top right corner of the
  /// toggle is used as anchor.
  topRight,

  /// The left center of the
  /// toggle is used as anchor.
  leftCenter,

  /// The very center of the
  /// toggle is used as anchor.
  center,

  /// The right center of the
  /// toggle is used as anchor.
  rightCenter,

  /// The bottom left corner of the
  /// toggle is used as anchor.
  bottomLeft,

  /// The bottom center of the
  /// toggle is used as anchor.
  bottomCenter,

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
  /// left edge to the [DropdownAnchor] and opens to the bottom right.
  downRight,

  /// The content will be positioned with the top
  /// right edge to the [DropdownAnchor] and opens to the bottom left.
  downLeft,
}

/// A generic dropdown widget that enables arbitrary content
/// with an arbitrary toggle widget. The content can be placed
/// relative to the toggle in any direction with the
/// [anchor] and [direction] configuration.
///
/// The offset enables additional possitioning options for the
/// content. The [contentBuilder] receives a "repaint" and a
/// "close" callbacks, which can help updating the content
/// or closing the content entirely.
final class GenericDropdown extends StatefulWidget {
  /// The anchor of the dropdown. Defines
  /// on which point of the toggle the content
  /// will be anchored. Defaults to [DropdownAnchor.bottomLeft].
  final DropdownAnchor anchor;

  /// Whether the content should close if any click/tap happens
  /// outside the content container. Defaults to `true`.
  final bool closeOnOutsideTap;

  /// A builder for the content of the dropdown. Creates the
  /// content of the dropdown.
  ///
  /// This builder inserts two callbacks to the child that can be called from content
  /// components: [repaint] and [close]. The [repaint] will trigger a "setState" in the
  /// content and should repaint the content (to update objects inside the content), while
  /// [close] will close the dropdown.
  final ContentBuilder contentBuilder;

  /// The direction of the content. Defines
  /// how the content will be "opened".
  /// Defaults to [DropdownDirection.downRight].
  final DropdownDirection direction;

  /// Additional offset to the dropdown position.
  /// The offset is calculated in the direction of the
  /// [DropdownDirection]. Defaults to [Offset.zero].
  final Offset offset;

  /// Whether the content (dropdown) should be opened on render.
  /// Defaults to `false`.
  final bool openOnRender;

  /// The widget that will be used to toggle the dropdown.
  /// Receives a boolean value (`isOpen`) that indicates if the content
  /// is shown or not.
  /// Be aware that if the widget you return captures mouse events,
  /// you need to ensure that the mouse events are passed to the dropdown.
  final ToggleBuilder toggleBuilder;

  /// The color of the barrier that is shown when the dropdown is open.
  /// Defaults to `Colors.transparent`.
  /// This spans the entire screen.
  final Color barrierColor;

  const GenericDropdown(
      {super.key,
      required this.contentBuilder,
      this.anchor = DropdownAnchor.bottomLeft,
      this.direction = DropdownDirection.downRight,
      required this.toggleBuilder,
      this.closeOnOutsideTap = true,
      this.openOnRender = false,
      this.barrierColor = Colors.transparent,
      this.offset = Offset.zero});

  @override
  State<GenericDropdown> createState() => _GenericDropdownState();
}

final class _GenericDropdownState extends State<GenericDropdown> {
  var _isOpen = false;
  OverlayEntry? _overlayEntry;

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
      GenericDropdownConfigProvider.of(context)
          ?.rootScreenKey
          ?.currentContext
          ?.findRenderObject() as RenderBox?;

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _open(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;

    final size = renderBox.size;
    final togglePosition =
        renderBox.localToGlobal(Offset.zero, ancestor: _ancestor(context));

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
    if (widget.anchor == DropdownAnchor.topLeft) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx;
      }
    }

    // Anchor TOP CENTER
    if (widget.anchor == DropdownAnchor.topCenter) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      }
    }

    // Anchor TOP RIGHT
    if (widget.anchor == DropdownAnchor.topRight) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height - togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx + size.width;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy;
        left = togglePosition.dx + widget.offset.dx + size.width;
      }
    }

    // Anchor LEFT CENTER
    if (widget.anchor == DropdownAnchor.leftCenter) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        left = togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        left = togglePosition.dx + widget.offset.dx;
      }
    }

    // Anchor CENTER
    if (widget.anchor == DropdownAnchor.center) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      }
    }

    // Anchor RIGHT CENTER
    if (widget.anchor == DropdownAnchor.rightCenter) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height / 2;
        left = togglePosition.dx + widget.offset.dx + size.width;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height / 2;
        left = togglePosition.dx + widget.offset.dx + size.width;
      }
    }

    // Anchor BOTTOM LEFT
    if (widget.anchor == DropdownAnchor.bottomLeft) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        left = togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        right = screenSize.width - togglePosition.dx + widget.offset.dx;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        left = togglePosition.dx + widget.offset.dx;
      }
    }

    // Anchor BOTTOM CENTER
    if (widget.anchor == DropdownAnchor.bottomCenter) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width / 2;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        left = togglePosition.dx + widget.offset.dx + size.width / 2;
      }
    }

    // Anchor BOTTOM RIGHT
    if (widget.anchor == DropdownAnchor.bottomRight) {
      if (widget.direction == DropdownDirection.upLeft) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.upRight) {
        bottom = screenSize.height -
            togglePosition.dy +
            widget.offset.dy -
            size.height;
        left = togglePosition.dx + widget.offset.dx + size.width;
      } else if (widget.direction == DropdownDirection.downLeft) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        right = screenSize.width -
            togglePosition.dx +
            widget.offset.dx -
            size.width;
      } else if (widget.direction == DropdownDirection.downRight) {
        top = togglePosition.dy + widget.offset.dy + size.height;
        left = togglePosition.dx + widget.offset.dx + size.width;
      }
    }

    Size? contentSize;
    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => widget.closeOnOutsideTap ? _close() : null,
          child: Container(
            alignment: Alignment.topLeft,
            color: widget.barrierColor,
            child: Stack(
              children: [
                StatefulBuilder(builder: (context, setState) {
                  if (contentSize != null) {
                    if (top != null &&
                        top! + contentSize!.height > screenSize.height) {
                      top = screenSize.height - contentSize!.height;
                    }

                    if (bottom != null &&
                        bottom! + contentSize!.height > screenSize.height) {
                      bottom = screenSize.height - contentSize!.height;
                    }

                    if (left != null &&
                        left! + contentSize!.width > screenSize.width) {
                      left = screenSize.width - contentSize!.width;
                    }

                    if (right != null &&
                        right! + contentSize!.width > screenSize.width) {
                      right = screenSize.width - contentSize!.width;
                    }

                    final isWiderThanScreen =
                        contentSize!.width > screenSize.width;
                    final isTallerThanScreen =
                        contentSize!.height > screenSize.height;

                    if (isWiderThanScreen) {
                      left = 0;
                      right = 0;
                    }

                    if (isTallerThanScreen) {
                      top = 0;
                      bottom = 0;
                    }
                  }

                  return Positioned(
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
                      child: _MeasureSize(
                        onChange: (size) => setState(() => contentSize = size),
                        child: StatefulBuilder(
                            builder: (context, setState) => widget
                                .contentBuilder
                                .call(context, () => setState(() {}), _close)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() => _isOpen = true);
  }

  Size _screenSize(BuildContext context) =>
      _ancestor(context)?.size ?? MediaQuery.of(context).size;
}

final class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? _oldSize;

  final void Function(Size size) onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;
    if (_oldSize == newSize || newSize == null) {
      return;
    }

    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  final void Function(Size size) onChange;

  const _MeasureSize({
    super.child,
    required this.onChange,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);
}
