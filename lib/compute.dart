import 'dart:math';
import 'package:tuple/tuple.dart';

import 'package:brick_wall_designer/consts.dart';

class Brick {
  final int width;
  final int height;
  final int x;
  int y;

  Brick(this.width, this.height, this.x, this.y);
}

Tuple2<List<Brick>, bool> compute(List<int> brickLengths,
    List<int> brickHeights, int wallLength, int wallHeight, WallType wallType) {
  int numBricks = brickLengths.length;
  List<int> brickH2Lengths = [];
  List<int> brickH3Lengths = [];
  for (int brickId = 0; brickId < numBricks; brickId++) {
    if (brickHeights[brickId] == 2) {
      brickH2Lengths.add(brickLengths[brickId]);
    } else if (brickHeights[brickId] == 3) {
      brickH3Lengths.add(brickLengths[brickId]);
    }
  }
  int bottomId = 0;
  List<List<int>> takenBrickHeight = List.generate(
    wallLength,
    (index) => List<int>.filled(wallHeight, 0),
  );

  Set<Tuple2<int, int>> gapPositionsSet = <Tuple2<int, int>>{};
  List<Brick> bricks = [];

  bool levelStartsAt(int level, int endX) {
    return gapPositionsSet.contains(Tuple2(endX, level));
  }

  void fill(Brick brick) {
    bricks.add(brick);
    if (brick.y == 0) {
      bottomId++;
    }
    for (int bx = brick.x; bx < brick.x + brick.width; bx++) {
      if (bx < wallLength) {
        for (int by = brick.y; by < brick.y + brick.height; by++) {
          takenBrickHeight[bx][by] = brick.height;
          if (bx == brick.x) {
            gapPositionsSet.add(Tuple2(bx, by));
            gapPositionsSet.add(Tuple2(bx + brick.width, by));
          }
        }
      }
    }
  }

  // Check it physically fits
  bool physicalFit(int brickId, int x, int y) {
    if (y + brickHeights[brickId] > wallHeight) {
      return false;
    }
    for (int by = y; by < y + brickHeights[brickId]; by++) {
      if (takenBrickHeight[x][by] > 0) {
        return false;
      }
    }
    return true;
  }

  // Check it satisfies type conditions
  bool typeConditions(int brickId, int x, int y) {
    if (wallType == WallType.scottish) {
      if ((y == 0 && brickHeights[brickId] == 1) ||
          (y > 0 && brickHeights[brickId] > 1)) {
        // Don't allow height 2 bricks here to not get too many
        return false;
      }
    } else if (wallType == WallType.layered) {
      if (x > 0) {
        // Previous brick does not have same height
        if (takenBrickHeight[x - 1][y] != brickHeights[brickId]) {
          return false;
        }
      }
    }
    return true;
  }

  // Check whether H2 brick has another H2 brick below or above
  hasH2Adjacent(Brick h2Brick) {
    for (int x = h2Brick.x; x < h2Brick.x + h2Brick.width; x++) {
      if (x < wallLength) {
        if (h2Brick.y > 0 && takenBrickHeight[x][h2Brick.y - 1] == 2) {
          return true;
        }
        if (h2Brick.y + 1 < wallHeight &&
            takenBrickHeight[x][h2Brick.y + 1] == 2) {
          return true;
        }
      }
    }
    return false;
  }

  // Try placing a height 1 brick above a bottom height 2 brick such that their ends match
  // Return true if it succeeds
  bool tryPlaceH1AboveH2(int brickId, int bx, int by) {
    if (bx + brickLengths[brickId] >= wallLength) {
      return true;
    }
    int neededLength = 0;
    int startH1 = -1;
    for (int x = bx; x < wallLength; x++) {
      if (takenBrickHeight[x][2] == 0) {
        neededLength = (bx + brickLengths[brickId] - x);
        startH1 = x;
        break;
      }
    }
    for (int height1Id = 0; height1Id < brickLengths.length; height1Id++) {
      if (brickHeights[height1Id] == 1 &&
          brickLengths[height1Id] == neededLength) {
        fill(Brick(neededLength, 1, startH1, 2));
        return true;
      }
    }
    return false;
  }

  // Check whether the brick would cause two stacked aligned gaps.
  // If yes the only allowed case is two gaps and adding a height two brick.
  // In this case add the height two brick directly.
  bool handleStackedGaps(int brickId, int x, int y) {
    int brickEndX = x + brickLengths[brickId];
    if (brickEndX < wallLength) {
      int belowLevel = y - 1;
      bool isBelowSame =
          belowLevel >= 0 && levelStartsAt(belowLevel, brickEndX);
      int aboveLevel = y + brickHeights[brickId];
      bool isAboveSame =
          aboveLevel < wallHeight && levelStartsAt(aboveLevel, brickEndX);
      if (isBelowSame || isAboveSame) {
        if ((isBelowSame && isAboveSame) || wallType == WallType.layered) {
          // Don't allow stacked gaps in these cases
          return false;
        }
        if (y == 0 && wallType == WallType.scottish) {
          return false;
        }
        if (brickHeights[brickId] == 1) {
          // H2 = Height two brick
          int belowH2Level = belowLevel - (isBelowSame ? 1 : 0);
          int aboveH2Level = aboveLevel + (isAboveSame ? 1 : 0);
          assert(aboveH2Level - belowH2Level == 3);
          // Same gap or also height 2
          bool isAdditionalBelowSame =
              belowH2Level >= 0 && levelStartsAt(belowH2Level, brickEndX);
          bool isAdditionalAboveSame = aboveH2Level < wallHeight &&
              levelStartsAt(aboveH2Level, brickEndX);
          if (isAdditionalBelowSame || isAdditionalAboveSame) {
            // Don't allow 3 aligned stacked brick gaps
            return false;
          } else {
            // Exactly 2 with same length, try putting brick with height 2
            brickH2Lengths.shuffle(Random());
            for (int brickH2Length in brickH2Lengths) {
              int brickH2EndX = brickEndX + brickH2Length;
              bool belowH2Same = brickH2EndX < wallLength &&
                  belowH2Level >= 0 &&
                  levelStartsAt(belowH2Level, brickH2EndX);
              bool aboveH2Same = brickH2EndX < wallLength &&
                  aboveH2Level < wallHeight &&
                  levelStartsAt(aboveH2Level, brickH2EndX);
              if (!belowH2Same &&
                  !aboveH2Same &&
                  !hasH2Adjacent(
                      Brick(brickH2Length, 2, brickEndX, belowH2Level + 1))) {
                // Add the height two block, avoiding stacked gap
                fill(Brick(brickH2Length, 2, brickEndX, belowH2Level + 1));
                return true;
              }
            }
            return false;
          }
        } else {
          return false;
        }
      } else if (wallType == WallType.scottish && y == 0) {
        if (brickHeights[brickId] !=
            scottishPattern[bottomId % scottishPattern.length]) {
          // Height does not match desired pattern
          return false;
        } else if (brickHeights[brickId] == 2 &&
            scottishPattern[(bottomId + 1) % scottishPattern.length] == 3) {
          // If next brick should have height 3 ensure it works out with height 1 brick above height 2 brick
          if (!tryPlaceH1AboveH2(brickId, x, y)) {
            return false;
          }
        } else if (brickHeights[brickId] == 3) {
          if (scottishPattern[(bottomId + 1) % scottishPattern.length] == 3 ||
              scottishPattern[(bottomId + scottishPattern.length - 1) %
                      scottishPattern.length] ==
                  3) {
            // Ensure brick is not too long when two consecutive height 3
            int averageH3BrickLength = brickH3Lengths.isEmpty
                ? 0
                : brickH3Lengths.fold(0, (value, element) => value + element) ~/
                    brickH3Lengths.length;
            if (brickLengths[brickId] > averageH3BrickLength) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  // Check that all conditions are satisfied
  bool goodFit(int brickId, int x, int y) {
    if (!physicalFit(brickId, x, y) ||
        !typeConditions(brickId, x, y) ||
        !handleStackedGaps(brickId, x, y)) {
      return false;
    }
    return true;
  }

  for (int x = 0; x < wallLength; x++) {
    for (int y = 0; y < wallHeight; y++) {
      if (takenBrickHeight[x][y] == 0) {
        List<int> permutation = List.generate(numBricks, (index) => index);
        permutation.shuffle(Random());
        for (int brickId in permutation) {
          if (goodFit(brickId, x, y)) {
            fill(Brick(brickLengths[brickId], brickHeights[brickId], x, y));
            break;
          }
        }
      }
    }
  }
  // Make y-coordinates increase upwards
  for (int chosenBrickId = 0; chosenBrickId < bricks.length; chosenBrickId++) {
    bricks[chosenBrickId].y =
        wallHeight - bricks[chosenBrickId].y - bricks[chosenBrickId].height + 1;
  }
  bool success = true;
  for (int x = 0; x < wallLength; x++) {
    for (int y = 0; y < wallHeight; y++) {
      if (takenBrickHeight[x][y] == 0) {
        success = false;
      }
    }
  }
  return Tuple2(bricks, success);
}
