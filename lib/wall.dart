import 'package:flutter/material.dart';

import 'package:brick_wall_designer/consts.dart';
import 'package:brick_wall_designer/compute.dart';

class BrickPainter extends CustomPainter {
  final List<Brick> bricks;
  final double scale;

  BrickPainter(this.bricks, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < bricks.length; i++) {
      double left = bricks[i].x * scale;
      double top = bricks[i].y * scale;
      double width = bricks[i].width * scale;
      double height = bricks[i].height * scale;

      Rect rect = Rect.fromLTWH(left, top, width, height);
      canvas.drawRect(rect, paint);

      // Draw the length of the brick
      TextSpan textSpan = TextSpan(
        text: '${bricks[i].width}',
        style: const TextStyle(color: Colors.black),
      );
      TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      double textX = left + width / 2 - textPainter.width / 2;
      double textY = top + height / 2 - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Wall extends StatelessWidget {
  final List<Brick> bricks;
  final int length;
  final int height;
  final double scale;

  const Wall(
      {super.key,
      required this.bricks,
      required this.length,
      required this.height})
      : scale = height > maxWallHeight ? 1.0 : maxWallHeight / height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: BrickPainter(bricks, scale),
        size: Size(length * scale,
            height * scale), // Specify the desired size of the canvas
      ),
    );
  }
}
