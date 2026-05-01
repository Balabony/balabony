import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../screens/stories_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000512),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000512),
        title: const Text(
          'Ігри',
          style: TextStyle(
              color: Color(0xFFEF9F27),
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFEF9F27)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _StoriesFeaturedCard(
              onTap: () => Navigator.pushNamed(context, '/stories'),
            ),
            const SizedBox(height: 28),
            _GameCard(
              title: 'Словесний конструктор',
              description: 'Складай слова з літер великого слова',
              iconPainter: _LeafPainter(),
              onTap: () => Navigator.pushNamed(context, '/word-builder'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Знайди пару',
              description: 'Знаходь пари однакових карток',
              iconPainter: _DiamondPainter(),
              onTap: () => Navigator.pushNamed(context, '/memory'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Числові доріжки',
              description: 'Логічна гра Судоку 4×4',
              iconPainter: _GridPainter(),
              onTap: () => Navigator.pushNamed(context, '/sudoku'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Вгадай слово',
              description: 'Вгадай українське слово за 6 спроб',
              iconPainter: _StarPainter(),
              onTap: () => Navigator.pushNamed(context, '/wordle'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Ланцюжок слів',
              description: 'Утворюй слова з останньої літери попереднього',
              iconPainter: _ChainPainter(),
              onTap: () => Navigator.pushNamed(context, '/word-chain'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Анаграма',
              description: 'Склади слово з перемішаних літер',
              iconPainter: _ShufflePainter(),
              onTap: () => Navigator.pushNamed(context, '/anagram'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Математика',
              description: 'Розв\'язуй математичні приклади на час',
              iconPainter: _MathPainter(),
              onTap: () => Navigator.pushNamed(context, '/math-game'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Знайди зайве',
              description: 'Знайди слово яке не підходить до групи',
              iconPainter: _OddPainter(),
              onTap: () => Navigator.pushNamed(context, '/odd-one-out'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Прислів\'я',
              description: 'Склади українське прислів\'я',
              iconPainter: _ProverbPainter(),
              onTap: () => Navigator.pushNamed(context, '/proverbs'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Пазл',
              description: 'Склади картинку з частин',
              iconPainter: _PuzzlePainter(),
              onTap: () => Navigator.pushNamed(context, '/puzzle'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Вікторина',
              description: 'Відповідай на питання про Україну',
              iconPainter: _QuizPainter(),
              onTap: () => Navigator.pushNamed(context, '/quiz'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Натисни вчасно',
              description: 'Перевір швидкість своєї реакції',
              iconPainter: _ReactionPainter(),
              onTap: () => Navigator.pushNamed(context, '/reaction'),
            ),
            const SizedBox(height: 20),
            _GameCard(
              title: 'Послідовність',
              description: 'Запам\'ятай і повтори послідовність',
              iconPainter: _SequencePainter(),
              onTap: () => Navigator.pushNamed(context, '/sequence'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoriesFeaturedCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StoriesFeaturedCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f1e3a), Color(0xFF040D20)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF9F27), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF9F27).withOpacity(0.12),
                border: Border.all(
                  color: const Color(0xFFEF9F27).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Аудіоісторії',
                    style: TextStyle(
                      color: Color(0xFFEF9F27),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Слухайте казки та оповідання',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge('3 безкоштовно', false),
                      const SizedBox(width: 8),
                      _badge('✦ 5 преміум', true),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFEF9F27),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, bool gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: gold
            ? const Color(0xFFEF9F27).withOpacity(0.15)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: gold
              ? const Color(0xFFEF9F27).withOpacity(0.4)
              : Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: gold
              ? const Color(0xFFEF9F27)
              : Colors.white.withOpacity(0.5),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final CustomPainter iconPainter;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.iconPainter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEF9F27), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF040D20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(painter: iconPainter),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Color(0xFFEF9F27),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text(description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFEF9F27)),
          ],
        ),
      ),
    );
  }
}

// ─── Іконки ──────────────────────────────────────────────────────────────────

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;
    final path = Path();
    path.moveTo(cx, cy - r);
    path.quadraticBezierTo(cx + r, cy, cx, cy + r);
    path.quadraticBezierTo(cx - r, cy, cx, cy - r);
    path.close();
    canvas.drawPath(
        path,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawPath(
        path,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27));
    canvas.drawLine(
        Offset(cx, cy - r * 0.8),
        Offset(cx, cy + r * 0.8),
        p
          ..strokeWidth = 1
          ..color = const Color(0xFFEF9F27).withOpacity(0.5));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = Path()
      ..moveTo(cx, cy * 0.1)
      ..lineTo(size.width * 0.9, cy)
      ..lineTo(cx, cy * 1.9)
      ..lineTo(size.width * 0.1, cy)
      ..close();
    canvas.drawPath(
        outer,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawPath(
        outer,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27));
    final inner = Path()
      ..moveTo(cx, cy * 0.45)
      ..lineTo(size.width * 0.7, cy)
      ..lineTo(cx, cy * 1.55)
      ..lineTo(size.width * 0.3, cy)
      ..close();
    canvas.drawPath(inner, p..color = const Color(0xFF7A5010));
    canvas.drawCircle(
        Offset(cx, cy),
        3,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final s = size.width * 0.85;
    final ox = (size.width - s) / 2;
    final oy = (size.height - s) / 2;
    canvas.drawRect(Rect.fromLTWH(ox, oy, s, s), p);
    canvas.drawLine(
        Offset(ox + s / 2, oy), Offset(ox + s / 2, oy + s), p..strokeWidth = 2);
    canvas.drawLine(
        Offset(ox, oy + s / 2), Offset(ox + s, oy + s / 2), p..strokeWidth = 2);
    canvas.drawLine(
        Offset(ox + s / 4, oy),
        Offset(ox + s / 4, oy + s),
        p
          ..strokeWidth = 0.8
          ..color = const Color(0xFF7A5010));
    canvas.drawLine(Offset(ox + s * 3 / 4, oy), Offset(ox + s * 3 / 4, oy + s),
        p..strokeWidth = 0.8);
    canvas.drawLine(Offset(ox, oy + s / 4), Offset(ox + s, oy + s / 4), p);
    canvas.drawLine(
        Offset(ox, oy + s * 3 / 4), Offset(ox + s, oy + s * 3 / 4), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = i * 2 * pi / 5 - pi / 2;
      final inner = outer + pi / 5;
      final ox = cx + cos(outer) * r;
      final oy = cy + sin(outer) * r;
      final ix = cx + cos(inner) * r * 0.4;
      final iy = cy + sin(inner) * r * 0.4;
      if (i == 0)
        path.moveTo(ox, oy);
      else
        path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, p..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawPath(
        path,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27)
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ChainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.12;
    final centers = [
      Offset(cx - size.width * 0.3, cy),
      Offset(cx, cy),
      Offset(cx + size.width * 0.3, cy),
    ];
    for (final c in centers) {
      canvas.drawCircle(
          c,
          r,
          p
            ..style = PaintingStyle.fill
            ..color = const Color(0xFFEF9F27).withOpacity(0.15));
      canvas.drawCircle(
          c,
          r,
          p
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFFEF9F27));
    }
    canvas.drawLine(
        Offset(centers[0].dx + r, cy),
        Offset(centers[1].dx - r, cy),
        p
          ..strokeWidth = 2
          ..color = const Color(0xFFEF9F27));
    canvas.drawLine(
        Offset(centers[1].dx + r, cy), Offset(centers[2].dx - r, cy), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ShufflePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27));
    final tp = TextPainter(
      text: const TextSpan(
          text: 'А',
          style: TextStyle(
              color: Color(0xFFEF9F27),
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx + 12, cy), p);
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 12), p);
    canvas.drawCircle(
        Offset(cx - 14, cy - 14), 3, p..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + 14, cy + 14), 3, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _OddPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.12;
    final positions = [
      Offset(cx - 14, cy - 10),
      Offset(cx + 14, cy - 10),
      Offset(cx - 14, cy + 10),
    ];
    for (final pos in positions) {
      canvas.drawCircle(
          pos,
          r,
          p
            ..style = PaintingStyle.fill
            ..color = const Color(0xFFEF9F27).withOpacity(0.15));
      canvas.drawCircle(
          pos,
          r,
          p
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFFEF9F27));
    }
    canvas.drawCircle(
        Offset(cx + 14, cy + 10),
        r,
        p
          ..style = PaintingStyle.fill
          ..color = Colors.red.withOpacity(0.2));
    canvas.drawCircle(
        Offset(cx + 14, cy + 10),
        r,
        p
          ..style = PaintingStyle.stroke
          ..color = Colors.red);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ProverbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final ox = size.width * 0.1;
    final oy = size.height * 0.2;
    final w = size.width * 0.8;
    for (int i = 0; i < 4; i++) {
      final y = oy + i * size.height * 0.18;
      final lineW = i == 3 ? w * 0.6 : w;
      canvas.drawLine(Offset(ox, y), Offset(ox + lineW, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PuzzlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final s = size.width * 0.4;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx - s / 2, cy - s / 2), width: s, height: s),
        p..color = const Color(0xFFEF9F27));
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx + s / 2, cy - s / 2), width: s, height: s),
        p);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx - s / 2, cy + s / 2), width: s, height: s),
        p);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx + s / 2, cy + s / 2), width: s, height: s),
        p..color = const Color(0xFF7A5010));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _QuizPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27));
    final tp = TextPainter(
      text: const TextSpan(
          text: '?',
          style: TextStyle(
              color: Color(0xFFEF9F27),
              fontSize: 22,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ReactionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35;
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFEF9F27).withOpacity(0.15));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        p
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFEF9F27));
    canvas.drawLine(
        Offset(cx, cy - r * 0.6),
        Offset(cx, cy),
        p
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.4, cy + r * 0.2), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SequencePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFEF9F27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.12;
    final positions = [
      Offset(cx - 16, cy - 8),
      Offset(cx + 4, cy - 14),
      Offset(cx + 16, cy + 4),
      Offset(cx - 4, cy + 14),
    ];
    final colors = [
      const Color(0xFFEF9F27),
      const Color(0xFF7A5010),
      const Color(0xFFEF9F27),
      const Color(0xFF7A5010),
    ];
    for (int i = 0; i < positions.length; i++) {
      canvas.drawCircle(
          positions[i],
          r,
          p
            ..style = PaintingStyle.fill
            ..color = colors[i].withOpacity(0.3));
      canvas.drawCircle(
          positions[i],
          r,
          p
            ..style = PaintingStyle.stroke
            ..color = colors[i]);
      if (i < positions.length - 1) {
        canvas.drawLine(
            positions[i],
            positions[i + 1],
            p
              ..strokeWidth = 1
              ..color = const Color(0xFFEF9F27).withOpacity(0.5));
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
