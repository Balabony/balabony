import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ball_state.dart';

class BalabonaSpherePainter extends CustomPainter {
  final BallState state;
  final double animValue; // 0.0 - 1.0 from AnimationController
  final double amplitude; // 0.0 - 1.0 from microphone

  BalabonaSpherePainter({
    required this.state,
    required this.animValue,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.35;

    switch (state) {
      case BallState.idle:
        _paintIdle(canvas, center, baseRadius);
        break;
      case BallState.listening:
        _paintListening(canvas, center, baseRadius);
        break;
      case BallState.thinking:
        _paintThinking(canvas, center, baseRadius);
        break;
      case BallState.speaking:
        _paintSpeaking(canvas, center, baseRadius);
        break;
    }
  }

  void _paintIdle(Canvas canvas, Offset center, double baseRadius) {
    // Slow pulse: ±5% radius
    final pulse = math.sin(animValue * 2 * math.pi) * 0.05;
    final radius = baseRadius * (1.0 + pulse);

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1a237e).withOpacity(0.3),
          const Color(0xFF1a237e).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 1.4, glowPaint);

    // Main sphere
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFF3949ab),
          const Color(0xFF1a237e),
          const Color(0xFF0d1642),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    // Highlight
    _paintHighlight(canvas, center, radius);
  }

  void _paintListening(Canvas canvas, Offset center, double baseRadius) {
    // React to amplitude: 5-40% expansion
    final expansion = 0.05 + amplitude * 0.35;
    final radius = baseRadius * (1.0 + expansion);

    // Ripple rings
    for (int i = 1; i <= 3; i++) {
      final rippleRadius = radius + (i * 20.0 * amplitude);
      final rippleOpacity = (0.4 - i * 0.1) * amplitude;
      final ripplePaint = Paint()
        ..color = const Color(0xFFef9f27).withOpacity(rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFef9f27).withOpacity(0.4 * amplitude),
          const Color(0xFFef9f27).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius * 1.4, glowPaint);

    // Main sphere
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFFffd54f),
          const Color(0xFFef9f27),
          const Color(0xFFe65100),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    _paintHighlight(canvas, center, radius);
  }

  void _paintThinking(Canvas canvas, Offset center, double baseRadius) {
    final radius = baseRadius;

    // Rotating arc
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animValue * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final arcPaint = Paint()
      ..color = const Color(0xFF7b1fa2).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.2),
      0,
      math.pi * 1.5,
      false,
      arcPaint,
    );
    canvas.restore();

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7b1fa2).withOpacity(0.3),
          const Color(0xFF7b1fa2).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 1.3, glowPaint);

    // Main sphere
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFFab47bc),
          const Color(0xFF7b1fa2),
          const Color(0xFF4a148c),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    _paintHighlight(canvas, center, radius);
  }

  void _paintSpeaking(Canvas canvas, Offset center, double baseRadius) {
    // Gentle pulse while speaking
    final pulse = math.sin(animValue * 4 * math.pi) * 0.08;
    final radius = baseRadius * (1.0 + pulse);

    // Bright outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFef9f27).withOpacity(0.5),
          const Color(0xFFef9f27).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(center, radius * 1.6, glowPaint);

    // Main sphere — gold
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFFfff176),
          const Color(0xFFef9f27),
          const Color(0xFFe65100),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    _paintHighlight(canvas, center, radius);
  }

  void _paintHighlight(Canvas canvas, Offset center, double radius) {
    // Specular highlight (top-left)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.5,
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, highlightPaint);
  }

  @override
  bool shouldRepaint(BalabonaSpherePainter oldDelegate) =>
      oldDelegate.animValue != animValue ||
      oldDelegate.state != state ||
      oldDelegate.amplitude != amplitude;
}

// ── Main Sphere Widget ──

class BalabonySphere extends StatefulWidget {
  final BallState state;
  final double amplitude;
  final VoidCallback onTap;

  const BalabonySphere({
    super.key,
    required this.state,
    required this.amplitude,
    required this.onTap,
  });

  @override
  State<BalabonySphere> createState() => _BalabonySphereState();
}

class _BalabonySphereState extends State<BalabonySphere>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void didUpdateWidget(BalabonySphere old) {
    super.didUpdateWidget(old);
    if (widget.state == BallState.thinking) {
      _controller.duration = const Duration(milliseconds: 1200);
    } else if (widget.state == BallState.speaking) {
      _controller.duration = const Duration(milliseconds: 600);
    } else {
      _controller.duration = const Duration(milliseconds: 800);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: BalabonaSpherePainter(
            state: widget.state,
            animValue: _controller.value,
            amplitude: widget.amplitude,
          ),
          size: const Size(300, 300),
        ),
      ),
    );
  }
}
