import 'dart:math';
import 'package:flutter/material.dart';

class InteractiveBackground extends StatefulWidget {
  const InteractiveBackground({super.key});

  @override
  State<InteractiveBackground> createState() => _InteractiveBackgroundState();
}

class _InteractiveBackgroundState extends State<InteractiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  Offset? _mousePos;
  final Random _random = Random();
  final double _connectionDistance = 120.0;
  final double _mouseRadius = 150.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    
    // Density calculation similar to web: (width * height) / 9000
    final area = size.width * size.height;
    final count = (area / 9000).toInt();
    
    _particles = List.generate(count, (index) {
      return Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        directionX: (_random.nextDouble() * 0.4) - 0.2,
        directionY: (_random.nextDouble() * 0.4) - 0.2,
        size: _random.nextDouble() * 3 + 1,
        color: _random.nextBool() 
            ? const Color(0xFFFF6B00) // Primary Orange
            : const Color(0xFF2E86DE), // Accent Blue,
        baseX: 0, // Set in init
        baseY: 0,
        density: (_random.nextDouble() * 30) + 1,
      )..baseX = 0..baseY = 0; // Fixed in update
    });
    
    // Fix base positions
    for (var p in _particles) {
      p.baseX = p.x;
      p.baseY = p.y;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size);
        
        return MouseRegion(
          onHover: (event) {
            setState(() {
              _mousePos = event.localPosition;
            });
          },
          onExit: (event) {
            setState(() {
              _mousePos = null;
            });
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              _updateParticles(size);
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  connectionDistance: _connectionDistance,
                ),
                size: size,
              );
            },
          ),
        );
      },
    );
  }

  void _updateParticles(Size size) {
    for (var p in _particles) {
      // Mouse interaction
      if (_mousePos != null) {
        double dx = _mousePos!.dx - p.x;
        double dy = _mousePos!.dy - p.y;
        double distance = sqrt(dx * dx + dy * dy);
        
        if (distance < _mouseRadius) {
          double forceDirectionX = dx / distance;
          double forceDirectionY = dy / distance;
          double force = (_mouseRadius - distance) / _mouseRadius;
          double directionX = forceDirectionX * force * p.density;
          double directionY = forceDirectionY * force * p.density;
          
          p.x -= directionX;
          p.y -= directionY;
        } else {
          if (p.x != p.baseX) {
            double dx = p.x - p.baseX;
            p.x -= dx / 20;
          }
          if (p.y != p.baseY) {
            double dy = p.y - p.baseY;
            p.y -= dy / 20;
          }
        }
      }

      // Movement
      p.x += p.directionX;
      p.y += p.directionY;

      // Bounce off edges
      if (p.x > size.width || p.x < 0) {
        p.directionX = -p.directionX;
      }
      if (p.y > size.height || p.y < 0) {
        p.directionY = -p.directionY;
      }
    }
  }
}

class Particle {
  double x;
  double y;
  double directionX;
  double directionY;
  double size;
  Color color;
  double baseX;
  double baseY;
  double density;

  Particle({
    required this.x,
    required this.y,
    required this.directionX,
    required this.directionY,
    required this.size,
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.density,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double connectionDistance;

  ParticlePainter({
    required this.particles,
    required this.connectionDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clear handled by framework
    
    // Connect particles
    final linePaint = Paint()..strokeWidth = 1.0;

    for (int a = 0; a < particles.length; a++) {
      for (int b = a; b < particles.length; b++) {
        double dx = particles[a].x - particles[b].x;
        double dy = particles[a].y - particles[b].y;
        double distance = sqrt(dx * dx + dy * dy);

        if (distance < connectionDistance) {
          double opacity = 1 - (distance / connectionDistance);
          linePaint.color = const Color(0xFFFF6B00).withValues(alpha: opacity * 0.2);
          canvas.drawLine(
            Offset(particles[a].x, particles[a].y),
            Offset(particles[b].x, particles[b].y),
            linePaint,
          );
        }
      }
    }

    // Draw particles
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
