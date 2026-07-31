import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const SingularityApp());
}

class SingularityApp extends StatelessWidget {
  const SingularityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF010105),
      ),
      debugShowCheckedModeBanner: false,
      home: const BlackHoleGame(),
    );
  }
}

// --- DATA MODELS ---
class CosmicTarget {
  Offset position;
  double radius;
  double speed;
  int massValue;
  Color color;
  double orbitAngle;

  CosmicTarget({
    required this.position,
    required this.radius,
    required this.speed,
    required this.massValue,
    required this.color,
    this.orbitAngle = 0.0,
  });
}

class Singularity {
  Offset position;
  Offset velocity;
  double mass;
  List<Offset> eventHorizonTrail = [];

  Singularity({
    required this.position,
    required this.velocity,
    this.mass = 30.0,
  });
}

class HorizonRipple {
  Offset position;
  double opacity;
  String? label;

  HorizonRipple({required this.position, this.opacity = 1.0, this.label});
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.opacity = 1.0,
  });
}

// --- MAIN GAME WIDGET ---
class BlackHoleGame extends StatefulWidget {
  const BlackHoleGame({super.key});

  @override
  State<BlackHoleGame> createState() => _BlackHoleGameState();
}

class _BlackHoleGameState extends State<BlackHoleGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastFrameTime = Duration.zero;

  // Game Stats
  int totalMassConsumed = 0;
  int comboStreak = 0;
  bool isEvaporated = false;

  // Singularity Control
  Offset defaultSpawn = const Offset(120, 320);
  Singularity? activeBlackHole;
  Offset? dragCurrent;
  bool isAiming = false;

  // Space Objects
  final List<CosmicTarget> spaceTargets = [];
  final List<HorizonRipple> ripples = [];
  final List<Particle> particles = [];
  final math.Random rng = math.Random();

  double globalTime = 0.0;
  double hawkingRadiationRate = 0.05; 

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
    _spawnInitialCosmicTargets();
  }

  void _onTick(Duration elapsed) {
    if (_lastFrameTime == Duration.zero) {
      _lastFrameTime = elapsed;
      return;
    }

    double dt = (elapsed - _lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = elapsed;

    _updatePhysics(dt);
  }

  void _spawnInitialCosmicTargets() {
    spaceTargets.clear();
    for (int i = 0; i < 6; i++) {
      _spawnTarget();
    }
  }

  void _spawnTarget() {
    final double radius = 18.0 + rng.nextDouble() * 14.0;
    final int massVal = (radius * 1.5).round();

    final List<Color> targetColors = [
      Colors.amberAccent,
      Colors.deepOrangeAccent,
      Colors.lightBlueAccent,
      Colors.purpleAccent,
    ];

    spaceTargets.add(
      CosmicTarget(
        position: Offset(
          380.0 + rng.nextDouble() * 320.0,
          90.0 + rng.nextDouble() * 420.0,
        ),
        radius: radius,
        speed: (rng.nextBool() ? 1 : -1) * (1.0 + rng.nextDouble() * 2.0),
        massValue: massVal,
        color: targetColors[rng.nextInt(targetColors.length)],
        orbitAngle: rng.nextDouble() * math.pi * 2,
      ),
    );
  }

  void _spawnJetParticles(Offset pos, Color color, {int count = 22}) {
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = 2.0 + rng.nextDouble() * 7.0;
      particles.add(
        Particle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updatePhysics(double dt) {
    if (isEvaporated) return;

    final double frameScale = dt * 60.0;

    setState(() {
      globalTime += dt;

      for (int i = particles.length - 1; i >= 0; i--) {
        particles[i].position += particles[i].velocity * frameScale;
        particles[i].opacity -= 0.025 * frameScale;
        if (particles[i].opacity <= 0) particles.removeAt(i);
      }

      for (int i = ripples.length - 1; i >= 0; i--) {
        ripples[i].opacity -= 0.02 * frameScale;
        if (ripples[i].opacity <= 0) ripples.removeAt(i);
      }

      for (var target in spaceTargets) {
        target.orbitAngle += 0.03 * frameScale;
        target.position += Offset(
          math.sin(target.orbitAngle) * 0.8,
          target.speed * frameScale,
        );

        if (target.position.dy < 60 || target.position.dy > 580) {
          target.speed *= -1;
        }
      }

      if (activeBlackHole != null) {
        final bh = activeBlackHole!;
        bh.position += bh.velocity * frameScale;
        bh.eventHorizonTrail.add(bh.position);

        if (bh.eventHorizonTrail.length > 18) {
          bh.eventHorizonTrail.removeAt(0);
        }

        bh.mass -= hawkingRadiationRate * frameScale;

        for (int t = spaceTargets.length - 1; t >= 0; t--) {
          final target = spaceTargets[t];
          double dist = (bh.position - target.position).distance;

          if (dist < target.radius + (bh.mass * 0.5)) {
            comboStreak++;
            int gainedMass = target.massValue + (comboStreak * 5);
            bh.mass += gainedMass * 0.6;
            totalMassConsumed += gainedMass;

            _spawnJetParticles(target.position, target.color);

            ripples.add(
              HorizonRipple(
                position: target.position,
                label: "+$gainedMass M☉ ${comboStreak > 1 ? 'x$comboStreak' : ''}",
              ),
            );

            spaceTargets.removeAt(t);
            _spawnTarget();
            break;
          }
        }

        if (bh.mass <= 5.0 ||
            bh.position.dx > 1050 ||
            bh.position.dx < -100 ||
            bh.position.dy < -100 ||
            bh.position.dy > 800) {
          if (bh.mass <= 5.0) {
            _spawnJetParticles(bh.position, Colors.deepOrangeAccent, count: 30);
          }
          activeBlackHole = null;
          comboStreak = 0;
          isEvaporated = true;
        }
      }
    });
  }

  void _restartSingularity() {
    setState(() {
      totalMassConsumed = 0;
      comboStreak = 0;
      isEvaporated = false;
      activeBlackHole = null;
      ripples.clear();
      particles.clear();
      _spawnInitialCosmicTargets();
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (isEvaporated || activeBlackHole != null) return;
    setState(() {
      isAiming = true;
      dragCurrent = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isAiming) return;
    setState(() {
      dragCurrent = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!isAiming || dragCurrent == null) return;

    final pullVector = defaultSpawn - dragCurrent!;
    final double power = pullVector.distance.clamp(0.0, 180.0);

    if (power > 15.0) {
      final launchVelocity =
          (pullVector / pullVector.distance) * (power * 0.16);

      setState(() {
        activeBlackHole = Singularity(
          position: defaultSpawn,
          velocity: launchVelocity,
          mass: 35.0,
        );
      });
    }

    setState(() {
      isAiming = false;
      dragCurrent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: CosmicCanvasPainter(
                  defaultSpawn: defaultSpawn,
                  dragCurrent: dragCurrent,
                  isAiming: isAiming,
                  blackHole: activeBlackHole,
                  targets: spaceTargets,
                  ripples: ripples,
                  particles: particles,
                  time: globalTime,
                ),
              ),
            ),
          ),
          RepaintBoundary(
            child: Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL MASS: $totalMassConsumed M☉',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    activeBlackHole != null
                        ? 'SINGULARITY: ${activeBlackHole!.mass.toStringAsFixed(1)} M☉'
                        : 'READY TO LAUNCH',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: activeBlackHole != null
                          ? Colors.purpleAccent
                          : Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isEvaporated)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepOrangeAccent, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('HAWKING EVAPORATION',
                        style: TextStyle(color: Colors.deepOrangeAccent, fontFamily: 'Courier', fontSize: 20)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                      onPressed: _restartSingularity,
                      child: const Text('RESTART', style: TextStyle(fontFamily: 'Courier')),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- PAINTER ---
class CosmicCanvasPainter extends CustomPainter {
  final Offset defaultSpawn;
  final Offset? dragCurrent;
  final bool isAiming;
  final Singularity? blackHole;
  final List<CosmicTarget> targets;
  final List<HorizonRipple> ripples;
  final List<Particle> particles;
  final double time;

  CosmicCanvasPainter({
    required this.defaultSpawn,
    required this.dragCurrent,
    required this.isAiming,
    required this.blackHole,
    required this.targets,
    required this.ripples,
    required this.particles,
    required this.time,
  });

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
