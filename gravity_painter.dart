@override
  void paint(Canvas canvas, Size size) {
    _drawDeepSpaceBackground(canvas, size);

    for (var target in targets) {
      _drawCosmicTarget(canvas, target.position, target.radius, target.color);
    }

    for (var ripple in ripples) {
      _drawHorizonRipple(canvas, ripple.position, ripple.opacity, ripple.label);
    }

    for (var p in particles) {
      canvas.drawCircle(
        p.position,
        2.0,
        Paint()..color = p.color.withOpacity(p.opacity),
      );
    }

    if (blackHole != null) {
      final bh = blackHole!;
      _drawSingularity(canvas, bh.position, bh.mass);
    } else if (!isAiming) {
      _drawSingularity(canvas, defaultSpawn, 30.0);
    }

    if (isAiming && dragCurrent != null) {
      canvas.drawLine(defaultSpawn, dragCurrent!, Paint()..color = Colors.white.withOpacity(0.5)..strokeWidth = 2);
    }
  }

  void _drawDeepSpaceBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF010105));
  }

  void _drawSingularity(Canvas canvas, Offset pos, double mass) {
    final double radius = mass * 0.6;
    canvas.drawCircle(pos, radius, Paint()..color = Colors.purpleAccent.withOpacity(0.3));
    canvas.drawCircle(pos, radius * 0.6, Paint()..color = Colors.black);
  }

  void _drawCosmicTarget(Canvas canvas, Offset pos, double r, Color color) {
    canvas.drawCircle(pos, r, Paint()..color = color);
  }

  void _drawHorizonRipple(Canvas canvas, Offset pos, double opacity, String? label) {
    canvas.drawCircle(pos, (1.0 - opacity) * 40.0, Paint()..color = Colors.amberAccent.withOpacity(opacity)..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CosmicCanvasPainter oldDelegate) => true;
}
