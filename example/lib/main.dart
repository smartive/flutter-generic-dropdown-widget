import 'package:flutter/material.dart';
import 'package:generic_dropdown_widget/generic_dropdown_widget.dart';

void main() {
  runApp(const MyApp());
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generic Dropdown Test'),
      ),
      body: const Center(
        child: Dropdown(),
      ),
    );
  }
}

final class Dropdown extends StatelessWidget {
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
          color: Colors.blue.shade200,
          child: Center(
            child: TextButton(
              onPressed: close,
              child: const Text('Close'),
            ),
          ),
        ),
      );
}
