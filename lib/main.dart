import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:brick_wall_designer/compute.dart' as wc;
import 'package:brick_wall_designer/consts.dart';
import 'package:brick_wall_designer/wall.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tuple/tuple.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Wall Designer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Brick Wall Designer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();
  List<int> brickLengths = [16, 24, 32, 16, 24, 32, 40, 48, 16, 24, 32];
  List<int> brickHeights = [1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3];
  int wallLength = 500;
  int wallHeight = 10;
  List<wc.Brick> bricks = [];
  bool success = false;
  bool wallCreated = false;

  final outerScrollController = ScrollController();
  final wallScrollController = ScrollController();
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  WallType selectedWallType = WallType.scottish;

  double computePaintedWallWidth() {
    double averageBrickLength = brickLengths.isEmpty
        ? 0.0
        : brickLengths.fold(0, (value, element) => value + element) /
            brickLengths.length;
    double averageBrickHeight = brickHeights.isEmpty
        ? 0.0
        : brickHeights.fold(0, (value, element) => value + element) /
            brickHeights.length;
    double adaptFactor =
        min(1.0, averageBrickHeight / averageBrickLength * 3.0);
    return min(
        maxWallHeight / wallHeight * wallLength * adaptFactor, maxWallWidth);
  }

  Widget successWidget() {
    if (!wallCreated) {
      return const SizedBox(height: 24);
    }
    if (success) {
      return const Text("Creating wall succeeded");
    } else {
      return const Text(
        "Creating wall failed for some reason. Try to rerun or change the brick types",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  Widget brickCounts() {
    List<int> counts = List<int>.filled(brickLengths.length, 0);
    for (int takenBrick = 0; takenBrick < bricks.length; takenBrick++) {
      for (int possibleBrick = 0;
          possibleBrick < brickLengths.length;
          possibleBrick++) {
        if (bricks[takenBrick].width == brickLengths[possibleBrick] &&
            bricks[takenBrick].height == brickHeights[possibleBrick]) {
          counts[possibleBrick]++;
          break;
        }
      }
    }
    return Container(
      color: Colors.yellow[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: counts
              .asMap()
              .map((key, value) => MapEntry(
                    key,
                    Text(
                        'Brick type $key (${brickLengths[key]} x ${brickHeights[key]}): $value'),
                  ))
              .values
              .toList(),
        ),
      ),
    );
  }

  Widget wallWidget() {
    if (!wallCreated) {
      return const Text('Press "Design wall"');
    }
    return Center(
      child: Column(
        children: [
          Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 45.0),
              child: SizedBox(
                height: maxWallHeight,
                width: computePaintedWallWidth(),
                child: Wall(
                  bricks: bricks,
                  length: wallLength,
                  height: wallHeight,
                  paintWidth: computePaintedWallWidth(),
                ),
              )),
          const SizedBox(
            height: 35,
          )
        ],
      ),
    );
  }

  Future<Uint8List> captureWidgetAsImage(Widget widget) async {
    Uint8List image = await screenshotController.captureFromWidget(
        Container(
          color: Colors.yellow[100],
          padding: const EdgeInsets.all(30.0),
          child: widget,
        ),
        targetSize: Size(computePaintedWallWidth() + 500, maxWallHeight + 200));
    return image;
  }

  saveImage(Uint8List image) {
    // Encode our file in base64
    final base64 = base64Encode(image);

    // Create a download link
    final href = 'data:application/png;base64,$base64';
    final anchor = html.AnchorElement()
      ..href = href
      ..download = 'wall.png';

    // Trigger the download
    anchor.click();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors
              .white, // Set the background color of the form fields to white
        ),
        textTheme: Typography.blackCupertino,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Center(child: Text(widget.title)),
        ),
        body: Center(
          child: Scrollbar(
            thumbVisibility: true,
            controller: outerScrollController,
            child: SingleChildScrollView(
              controller: outerScrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Choose brick types you want to use',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('For each brick choose the width and height. '
                        'All entered numbers have to be integers. '
                        'For scottish wall there should be bricks of height 1, 2 and 3.'),
                    const SizedBox(height: 16),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: brickLengths.length + 3,
                      itemBuilder: (context, index) {
                        if (index == brickLengths.length) {
                          // + Add button
                          return ListTile(
                            title: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    brickLengths.add(0);
                                    brickHeights.add(0);
                                  });
                                },
                                child: const Text(
                                  '+ (Add brick type)',
                                ),
                              ),
                            ),
                          );
                        } else if (index == brickLengths.length + 1) {
                          // - Remove button
                          return ListTile(
                            title: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    brickLengths.removeLast();
                                    brickHeights.removeLast();
                                  });
                                },
                                child: const Text(
                                  '- (Remove last brick type)',
                                ),
                              ),
                            ),
                          );
                        } else if (index == brickLengths.length + 2) {
                          // Wall dimensions
                          return ListTile(
                            title: Center(
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Wall dimensions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ],
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Text(
                                  'length: ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      initialValue: wallLength.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          wallLength =
                                              int.tryParse(value) ?? wallLength;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'height: ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      initialValue: wallHeight.toString(),
                                      onChanged: (value) {
                                        wallHeight =
                                            int.tryParse(value) ?? wallHeight;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Bricks
                          return ListTile(
                            subtitle: Row(
                              children: [
                                Text(
                                  'Brick type ${index + 1}, length: ',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      initialValue:
                                          brickLengths[index].toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          brickLengths[index] =
                                              int.tryParse(value) ??
                                                  brickLengths[index];
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  ' height: ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      initialValue:
                                          brickHeights[index].toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          brickHeights[index] =
                                              int.tryParse(value) ??
                                                  brickHeights[index];
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('''
                      - Divide all heights by the same number to make them integers.
                      - Press "Design wall" again to get a different wall'''),
                    const SizedBox(height: 16),
                    const Text(
                      'Wall type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: DropdownButtonFormField(
                        value: selectedWallType,
                        items: WallType.values.map((WallType wallType) {
                          return DropdownMenuItem<WallType>(
                            value: wallType,
                            child: Text(wallType.toString()),
                          );
                        }).toList(),
                        onChanged: (wallType) {
                          setState(() {
                            selectedWallType = wallType!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          for (int attempt = 0; attempt < 5; attempt++) {
                            Tuple2<List<wc.Brick>, bool> result = wc.compute(
                              brickLengths,
                              brickHeights,
                              wallLength,
                              wallHeight,
                              selectedWallType,
                            );
                            success = result.item2;
                            if (success) {
                              bricks = result.item1;
                              wallCreated = true;
                              break;
                            }
                          }
                        });
                      },
                      child: const Text('Design wall'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Wall',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.yellow[100],
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 20.0,
                        // ignore: deprecated_member_use
                        hoverThickness: 25.0,
                        controller: wallScrollController,
                        child: SingleChildScrollView(
                          controller: wallScrollController,
                          scrollDirection: Axis.horizontal,
                          child: wallWidget(),
                        ),
                      ),
                    ),
                    successWidget(),
                    const SizedBox(height: 8),
                    const Text(
                      'Brick counts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    brickCounts(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Uint8List image =
                            await captureWidgetAsImage(wallWidget());
                        saveImage(image);
                      },
                      child: const Text(
                        'Save wall as png',
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
