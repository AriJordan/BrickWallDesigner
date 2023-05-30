import 'dart:math';

class Brick {
  final int width;
  final int height;
  final int x;
  final int y;

  Brick(this.width, this.height, this.x, this.y);
}

List<Brick> compute(List<int> brickLengths, List<int> brickHeights,
    int wallLength, int wallHeight) {
  int numBricks = brickLengths.length;
  List<List<bool>> taken = List.generate(
    wallLength,
    (index) => List<bool>.filled(wallHeight, false),
  );
  print(taken.length);
  print(taken[0].length);
  List<Brick> bricks = [];

  bool checkFits(int brickId, int x, int y) {
    if (y + brickHeights[brickId] >= wallHeight) {
      return false;
    }
    for (int by = y; by < y + brickHeights[brickId]; by++) {
      if (taken[x][by]) {
        return false;
      }
    }
    return true;
  }

  void fill(int brickId, int x, int y) {
    bricks.add(Brick(brickLengths[brickId], brickHeights[brickId], x,
        wallHeight - y - brickHeights[brickId] + 1));
    for (int bx = x; bx < x + brickLengths[brickId]; bx++) {
      if (bx < wallLength) {
        for (int by = y; by < y + brickHeights[brickId]; by++) {
          taken[bx][by] = true;
        }
      }
    }
  }

  for (int x = 0; x < wallLength; x++) {
    for (int y = 0; y < wallHeight; y++) {
      if (!taken[x][y]) {
        List<int> permutation = List.generate(numBricks, (index) => index);
        permutation.shuffle(Random());
        for (int brickId in permutation) {
          if (checkFits(brickId, x, y)) {
            fill(brickId, x, y);
            break;
          }
        }
      }
    }
  }
  print("Wall computed");
  return bricks;
}
