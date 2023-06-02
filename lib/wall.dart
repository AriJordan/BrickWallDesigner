import 'package:flutter/material.dart';

import 'package:brick_wall_designer/consts.dart';
import 'package:brick_wall_designer/compute.dart';

class BrickPainter extends CustomPainter {
  final List<Brick> bricks;
  final double heightScale;
  final double widthScale;
  final int wallLength;

  BrickPainter(this.bricks, this.heightScale, this.widthScale, this.wallLength);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < bricks.length; i++) {
      double left = bricks[i].x * widthScale;
      double top = bricks[i].y * heightScale;
      double width = bricks[i].width * widthScale;
      double height = bricks[i].height * heightScale;

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

      // Check if the label goes beyond the red line
      double redLineX = wallLength * widthScale;
      if (textX + textPainter.width > redLineX) {
        textX = redLineX - textPainter.width;
      }

      // Draw the red line
      Paint redLinePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1.0;
      canvas.drawLine(
          Offset(redLineX, top), Offset(redLineX, top + height), redLinePaint);

      // Draw the length of the brick
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
  final double heightScale;
  final double widthScale;
  final double paintWidth;

  const Wall(
      {super.key,
      required this.bricks,
      required this.length,
      required this.height,
      required this.paintWidth})
      : heightScale = height > maxWallHeight ? 1.0 : maxWallHeight / height,
        widthScale = length > paintWidth ? 1.0 : paintWidth / length;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: BrickPainter(bricks, heightScale, widthScale, length),
        size: Size(length * widthScale,
            height * heightScale), // Specify the desired size of the canvas
      ),
    );
  }
}
