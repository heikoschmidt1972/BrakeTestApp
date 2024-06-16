import 'dart:math';

import 'package:flutter/material.dart';

class Speedometer extends StatelessWidget {
  final double value, width, height, maxspeed;

  const Speedometer(
      {super.key,
      required this.value,
      required this.width,
      required this.height,
      required this.maxspeed});

  // ====================================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: MySpeedometerPainter(value / maxspeed),
        ));
  }
}

class MySpeedometerPainter extends CustomPainter {
  final double value;

  const MySpeedometerPainter(
      this.value); // {super.repaint, required this.value}

  @override
  void paint(Canvas canvas, Size size) {
    final mpx = size.width / 2;
    final mpy = size.height / 2;

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final trackPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawArc(rect, pi - 0.5, 0.5 + pi + 0.5, false, trackPaint);

    final valuePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawArc(rect, pi - 0.5, value * (0.5 + pi + 0.5), false, valuePaint);
    // value * (0.5 + pi + 0.5)
    final scalePaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawArc(rect, pi, 0.5, false, markerPaint);

    final double radius = 90;

    double a = 170;
    for (a = 170; a < 360; a += 5) {
      LineFromCenterToCircle(canvas, size, a, radius, 25);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  double AngleToRad(double angle) => (angle / 180) * pi;
  void LineFromCenterToCircle(
      Canvas canvas, Size size, double angle, double r, double l) {
    final mpx = size.width / 2;
    final mpy = size.height / 2;
    double x1, x2, y1, y2;
    final rad = AngleToRad(angle);
    final scalePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double mag1 = (r - 0.5 * l);
    final double mag2 = (r + 0.5 * l);
    x1 = cos(rad) * mag1 + mpx;
    x2 = cos(rad) * mag2 + mpx;
    y1 = sin(rad) * mag1 + mpy;
    y2 = sin(rad) * mag2 + mpy;

    final p1 = Offset(x1, y1);
    final p2 = Offset(x2, y2);
    canvas.drawLine(p1, p2, scalePaint);
  }
}
