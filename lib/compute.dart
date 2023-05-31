import 'dart:math';

import 'package:brick_wall_designer/consts.dart';

class Brick {
  final int width;
  final int height;
  final int x;
  final int y;

  Brick(this.width, this.height, this.x, this.y);
}

List<Brick> compute(List<int> brickLengths, List<int> brickHeights,
    int wallLength, int wallHeight, WallType wallType) {
  int numBricks = brickLengths.length;
  List<List<int>> takenHeight = List.generate(
    wallLength,
    (index) => List<int>.filled(wallHeight, 0),
  );
  List<Brick> bricks = [];

  bool checkFits(int brickId, int x, int y) {
    if (y + brickHeights[brickId] > wallHeight) {
      return false;
    }
    if (wallType == WallType.layered) {
      if (x > 0) {
        // Previous brick is lower
        if (takenHeight[x - 1][y + brickHeights[brickId] - 1] !=
            brickHeights[brickId]) {
          return false;
        }
        // Previous brick is higher
        if (y + brickHeights[brickId] < wallHeight &&
            takenHeight[x - 1][y + brickHeights[brickId]] != 1) {
          return false;
        }
      }
    } else if (wallType == WallType.scottish) {
      if (y == 0 && brickHeights[brickId] == 1) {
        return false;
      }
    }
    for (int by = y; by < y + brickHeights[brickId]; by++) {
      if (takenHeight[x][by] > 0) {
        assert(takenHeight[x][by] == 1);
        return false;
      }
    }
    return true;
  }

  bool checkFitsWell(int brickId, int x, int y) {
    if (y > 0 && brickHeights[brickId] > 2) {
      return false;
    }
    if (wallType == WallType.layered) {
      if (y > 0 && x + brickLengths[brickId] < wallLength) {
        // Ends at same place as below
        if (takenHeight[x + brickLengths[brickId] - 1][y - 1] != 0 &&
            takenHeight[x + brickLengths[brickId]][y - 1] == 0) {
          return false;
        }
      }
    } else {
      if (x > 0 && y + 1 < wallHeight) {
        // Brick 1 level above ends at same position but this brick only has height 1
        if (takenHeight[x - 1][y + 1] == 1 &&
            takenHeight[x][y + 1] == 0 &&
            brickHeights[brickId] == 1) {
          return false;
        } else if (y + 2 < wallHeight &&
            takenHeight[x][y + 1] == 0 &&
            takenHeight[x - 1][y + 2] == 1 &&
            takenHeight[x][y + 2] == 0 &&
            brickHeights[brickId] == 2) {
          return false;
        }
      }
    }
    return checkFits(brickId, x, y);
  }

  void fill(int brickId, int x, int y) {
    bricks.add(Brick(brickLengths[brickId], brickHeights[brickId], x,
        wallHeight - y - brickHeights[brickId] + 1));
    for (int bx = x; bx < x + brickLengths[brickId]; bx++) {
      if (bx < wallLength) {
        for (int by = y; by < y + brickHeights[brickId]; by++) {
          takenHeight[bx][by] = by - y + 1;
        }
      }
    }
  }

  for (int x = 0; x < wallLength; x++) {
    for (int y = 0; y < wallHeight; y++) {
      if (takenHeight[x][y] == 0) {
        List<int> permutation = List.generate(numBricks, (index) => index);
        permutation.shuffle(Random());
        bool done = false;
        for (int brickId in permutation) {
          if (checkFitsWell(brickId, x, y)) {
            fill(brickId, x, y);
            done = true;
            break;
          }
        }
        if (!done) {
          for (int brickId in permutation) {
            if (checkFits(brickId, x, y)) {
              fill(brickId, x, y);
              break;
            }
          }
        }
      }
    }
  }
  return bricks;
}
