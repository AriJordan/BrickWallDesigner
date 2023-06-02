import 'package:flutter/material.dart';

import 'package:brick_wall_designer/compute.dart';
import 'package:brick_wall_designer/consts.dart';
import 'package:brick_wall_designer/wall.dart';

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
  List<int> brickLengths = [16, 24, 32, 16, 24, 32, 40, 48, 16, 24, 32];
  List<int> brickHeights = [1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3];
  int wallLength = 1000;
  int wallHeight = 10;
  List<Brick> bricks = [];

  final outerScrollController = ScrollController();
  final wallScrollController = ScrollController();

  WallType selectedWallType = WallType.scottish;

  List<Widget> brickCounts() {
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
    return counts
        .asMap()
        .map((key, value) => MapEntry(key, Text('Brick type $key: $value')))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Scrollbar(
          thumbVisibility: true,
          controller: outerScrollController,
          child: SingleChildScrollView(
            controller: outerScrollController,
            child: Column(
              children: [
                const Text(
                  'Choose brick types you want to use',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                    'For each brick choose the width, height and the fraction of occurence (e.g. percenatge). '
                    'All entered numbers have to be integers. '
                    'For scottish wall there should be a bricks of height 1, 2 and possibly 3. '
                    'For other walls types there should be only bricks of height 1.'),
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
                        title: const Text(
                            'Wall dimensions (length, height), needs to be integer.'),
                        subtitle: Row(
                          children: [
                            Expanded(
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: wallHeight.toString(),
                                onChanged: (value) {
                                  wallHeight =
                                      int.tryParse(value) ?? wallHeight;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Bricks
                      return ListTile(
                        title: Text(
                          'Brick type ${index + 1} (length, height), needs to be integer.',
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: brickLengths[index].toString(),
                                onChanged: (value) {
                                  setState(() {
                                    brickLengths[index] = int.tryParse(value) ??
                                        brickLengths[index];
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: brickHeights[index].toString(),
                                onChanged: (value) {
                                  setState(() {
                                    brickHeights[index] = int.tryParse(value) ??
                                        brickHeights[index];
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('''
                    - Divide all heights by the same number to make them integers.
                    - Press "Design Wall" again to get a different wall'''),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                      bricks = compute(
                        brickLengths,
                        brickHeights,
                        wallLength,
                        wallHeight,
                        selectedWallType,
                      );
                    });
                  },
                  child: const Text('Design wall'),
                ),
                Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 20.0,
                  // ignore: deprecated_member_use
                  hoverThickness: 25.0,
                  controller: wallScrollController,
                  child: SingleChildScrollView(
                    controller: wallScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: SizedBox(
                                  height: maxWallHeight,
                                  width:
                                      maxWallHeight / wallHeight * wallLength,
                                  child: Wall(
                                    bricks: bricks,
                                    length: wallLength,
                                    height: wallHeight,
                                  ),
                                )),
                            const SizedBox(
                              height: 35,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Brick counts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...brickCounts(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
