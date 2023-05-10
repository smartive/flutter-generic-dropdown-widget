import 'package:flutter/material.dart';
import 'package:generic_dropdown_widget/generic_dropdown_widget.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

void main() {
  runApp(Storybook(
    plugins: initializePlugins(
      contentsSidePanel: true,
      knobsSidePanel: true,
      enableThemeMode: false,
    ),
    wrapperBuilder: (context, child) => MaterialApp(
        key: rootKey,
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        home: Scaffold(
            body: SafeArea(
                child: GenericDropdownConfigProvider(
                    rootScreenKey: rootKey,
                    child: Center(key: UniqueKey(), child: child))))),
    // initialStory: 'Generic Dropdown',
    stories: [_dropdown(), _openDropdown(), _dropdownAlignmentOverview()],
  ));
}

final rootKey = GlobalKey();

Story _dropdown() => Story(
    name: 'Generic Dropdown',
    description: 'A generic dropdown with arbirary toggle and content.',
    builder: (context) {
      var repaintCount = 1;

      return Align(
          alignment: context.knobs.options(
              label: 'Position',
              initial: Alignment.center,
              description:
                  'The position of the dropdown in this story, to test the content of the dropdown not going off-screen.',
              options: const [
                Option(label: 'Top Left', value: Alignment.topLeft),
                Option(label: 'Top Center', value: Alignment.topCenter),
                Option(label: 'Top Right', value: Alignment.topRight),
                Option(label: 'Center Left', value: Alignment.centerLeft),
                Option(label: 'Center', value: Alignment.center),
                Option(label: 'Center Right', value: Alignment.centerRight),
                Option(label: 'Bottom Left', value: Alignment.bottomLeft),
                Option(label: 'Bottom Center', value: Alignment.bottomCenter),
                Option(label: 'Bottom Right', value: Alignment.bottomRight),
              ]),
          child: GenericDropdown(
            contentBuilder: (context, repaint, close) => Container(
              height: 200,
              width: 300,
              color: Colors.green.withOpacity(.5),
              child: Column(
                children: [
                  const Text('Content'),
                  TextButton(onPressed: close, child: const Text('Close')),
                  TextButton(
                      onPressed: () {
                        repaintCount++;
                        repaint();
                      },
                      child: Text('Repaint (count: $repaintCount)')),
                ],
              ),
            ),
            toggleBuilder: (context, isOpen) => Container(
              height: 120,
              width: 120,
              color: isOpen
                  ? Colors.amber.withOpacity(.25)
                  : Colors.blue.withOpacity(.25),
              child: Text('Toggle (${isOpen ? 'Open' : 'Closed'})'),
            ),
            offset: Offset(
              context.knobs
                  .sliderInt(label: 'X Offset', initial: 0, min: -100, max: 100)
                  .toDouble(),
              context.knobs
                  .sliderInt(label: 'Y Offset', initial: 0, min: -100, max: 100)
                  .toDouble(),
            ),
            anchor: context.knobs.options(
                label: 'Anchor',
                description: 'The anchor for the content dropdown.',
                initial: DropdownAnchor.bottomLeft,
                options: DropdownAnchor.values
                    .map((v) => Option(label: v.name, value: v))
                    .toList()),
            direction: context.knobs.options(
                label: 'Direction',
                description: 'The direction where the dropdown should open to.',
                initial: DropdownDirection.downRight,
                options: DropdownDirection.values
                    .map((v) => Option(label: v.name, value: v))
                    .toList()),
            closeOnOutsideTap: context.knobs.boolean(
                label: 'Close On Outside Tap',
                description:
                    'Whether the content is closed on an outside tap or only if the content calls close().',
                initial: true),
          ));
    });

Story _dropdownAlignmentOverview() => Story(
    name: 'Generic Dropdown (alignement overview)',
    description: 'An overview over all possible anchors and directions.',
    builder: (context) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
              children: DropdownAnchor.values
                  .map((anchor) => Row(
                      children: DropdownDirection.values
                          .map((direction) => SizedBox(
                                width: 250,
                                height: 200,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Colors.black.withOpacity(.25))),
                                  child: Column(
                                    children: [
                                      Text(
                                        'anchor: ${anchor.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        'direction: ${direction.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: GenericDropdown(
                                            openOnRender: true,
                                            contentBuilder:
                                                (context, repaint, close) =>
                                                    Container(
                                              height: 40,
                                              width: 80,
                                              color:
                                                  Colors.green.withOpacity(.5),
                                              child: const Center(
                                                  child: Text('Content')),
                                            ),
                                            toggleBuilder: (context, _) =>
                                                Container(
                                              height: 60,
                                              width: 70,
                                              color:
                                                  Colors.amber.withOpacity(.25),
                                              child: const Center(
                                                  child: Text('Toggle')),
                                            ),
                                            anchor: anchor,
                                            offset: Offset(
                                              context.knobs
                                                  .sliderInt(
                                                      label: 'X Offset',
                                                      initial: 0,
                                                      min: -100,
                                                      max: 100)
                                                  .toDouble(),
                                              context.knobs
                                                  .sliderInt(
                                                      label: 'Y Offset',
                                                      initial: 0,
                                                      min: -100,
                                                      max: 100)
                                                  .toDouble(),
                                            ),
                                            direction: direction,
                                            closeOnOutsideTap: false,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(growable: false)))
                  .toList(growable: false)),
        ),
      );
    });

Story _openDropdown() => Story(
    name: 'Generic Dropdown (open)',
    description: 'A generic dropdown that opens on render.',
    builder: (context) {
      var repaintCount = 1;

      return Align(
          alignment: context.knobs.options(
              label: 'Position',
              initial: Alignment.center,
              description:
                  'The position of the dropdown in this story, to test the content of the dropdown not going off-screen.',
              options: const [
                Option(label: 'Top Left', value: Alignment.topLeft),
                Option(label: 'Top Center', value: Alignment.topCenter),
                Option(label: 'Top Right', value: Alignment.topRight),
                Option(label: 'Center Left', value: Alignment.centerLeft),
                Option(label: 'Center', value: Alignment.center),
                Option(label: 'Center Right', value: Alignment.centerRight),
                Option(label: 'Bottom Left', value: Alignment.bottomLeft),
                Option(label: 'Bottom Center', value: Alignment.bottomCenter),
                Option(label: 'Bottom Right', value: Alignment.bottomRight),
              ]),
          child: GenericDropdown(
            openOnRender: true,
            contentBuilder: (context, repaint, close) => Container(
              height: 200,
              width: 300,
              color: Colors.green.withOpacity(.5),
              child: Column(
                children: [
                  const Text('Content'),
                  TextButton(onPressed: close, child: const Text('Close')),
                  TextButton(
                      onPressed: () {
                        repaintCount++;
                        repaint();
                      },
                      child: Text('Repaint (count: $repaintCount)')),
                ],
              ),
            ),
            toggleBuilder: (context, isOpen) => Container(
              height: 120,
              width: 120,
              color: isOpen
                  ? Colors.amber.withOpacity(.25)
                  : Colors.blue.withOpacity(.25),
              child: Text('Toggle (${isOpen ? 'Open' : 'Closed'})'),
            ),
            offset: Offset(
              context.knobs
                  .sliderInt(label: 'X Offset', initial: 0, min: -100, max: 100)
                  .toDouble(),
              context.knobs
                  .sliderInt(label: 'Y Offset', initial: 0, min: -100, max: 100)
                  .toDouble(),
            ),
            anchor: context.knobs.options(
                label: 'Anchor',
                description: 'The anchor for the content dropdown.',
                initial: DropdownAnchor.bottomLeft,
                options: DropdownAnchor.values
                    .map((v) => Option(label: v.name, value: v))
                    .toList()),
            direction: context.knobs.options(
                label: 'Direction',
                description: 'The direction where the dropdown should open to.',
                initial: DropdownDirection.downRight,
                options: DropdownDirection.values
                    .map((v) => Option(label: v.name, value: v))
                    .toList()),
            closeOnOutsideTap: context.knobs.boolean(
                label: 'Close On Outside Tap',
                description:
                    'Whether the content is closed on an outside tap or only if the content calls close().',
                initial: true),
          ));
    });
