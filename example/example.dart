import 'package:flutter/material.dart';
import 'package:generic_dropdown_widget/generic_dropdown_widget.dart';

class Dropdown extends StatelessWidget {
  const Dropdown({super.key});

  @override
  Widget build(BuildContext context) => GenericDropdown(
        openOnRender: false,
        closeOnOutsideTap: true,
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
