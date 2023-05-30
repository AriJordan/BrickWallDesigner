import 'package:brick_wall_designer/compute.dart';
import 'package:brick_wall_designer/consts.dart';
import 'package:brick_wall_designer/wall.dart';
import 'package:flutter/material.dart';

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
  List<int> brickLengths = [16, 24, 32, 16, 24, 16];
  List<int> brickHeights = [1, 1, 1, 2, 2, 3];
  int wallLength = 1000;
  int wallHeight = 10;
  List<Brick> bricks = [];

  final outerScrollController = ScrollController();
  final wallScrollController = ScrollController();

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
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: brickLengths.length + 2,
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
                const Text('There must be a brick of height 1.'),
                const Text(
                    'Tip: divide all heights by the same number to make an integer.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      bricks = compute(
                        brickLengths,
                        brickHeights,
                        wallLength,
                        wallHeight,
                      );
                    });
                  },
                  child: const Text('Design wall'),
                ),
                Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 20.0,
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
                            SizedBox(
                              height: maxWallHeight,
                              width: maxWallHeight / wallHeight * wallLength,
                              child: Wall(
                                bricks: bricks,
                                length: wallLength,
                                height: wallHeight,
                              ),
                            ),
                            const SizedBox(
                              height: 35,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
