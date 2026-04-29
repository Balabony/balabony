import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

enum _Level { easy, medium, hard }

enum _Symbol {
  sun,
  moon,
  star,
  wave,
  leaf,
  mountain,
  drop,
  flame,
  crystal,
  spiral,
  eye,
  feather,
}

class _SymbolPainter extends CustomPainter {
  final _Symbol symbol;
  final Color color;
  final double opacity;

  _SymbolPainter(this.symbol,
      {this.color = const Color(0xFFEF9F27), this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withOpacity(opacity * 0.15)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    switch (symbol) {
      case _Symbol.sun:
        canvas.drawCircle(Offset(cx, cy), r * 0.5, fill);
        canvas.drawCircle(Offset(cx, cy), r * 0.5, paint);
        for (int i = 0; i < 8; i++) {
          final angle = i * pi / 4;
          final x1 = cx + cos(angle) * r * 0.65;
          final y1 = cy + sin(angle) * r * 0.65;
          final x2 = cx + cos(angle) * r;
          final y2 = cy + sin(angle) * r;
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        }
        break;

      case _Symbol.moon:
        final path = Path();
        path.addArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -pi / 2,
            pi * 1.5);
        path.arcTo(
            Rect.fromCircle(center: Offset(cx - r * 0.3, cy), radius: r * 0.75),
            pi / 2,
            -pi * 1.5,
            false);
        path.close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint);
        break;

      case _Symbol.star:
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
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint);
        break;

      case _Symbol.wave:
        final path = Path();
        path.moveTo(cx - r, cy);
        path.cubicTo(cx - r * 0.5, cy - r * 0.6, cx, cy + r * 0.6, cx + r * 0.5,
            cy - r * 0.3);
        path.cubicTo(cx + r * 0.7, cy - r * 0.6, cx + r, cy, cx + r, cy);
        canvas.drawPath(path, paint..strokeWidth = 2.5);
        final path2 = Path();
        path2.moveTo(cx - r, cy + r * 0.4);
        path2.cubicTo(
            cx - r * 0.5, cy - r * 0.2, cx, cy + r, cx + r * 0.5, cy + r * 0.1);
        path2.cubicTo(cx + r * 0.7, cy - r * 0.2, cx + r, cy + r * 0.4, cx + r,
            cy + r * 0.4);
        canvas.drawPath(
            path2,
            paint
              ..strokeWidth = 1.5
              ..color = color.withOpacity(opacity * 0.5));
        break;

      case _Symbol.leaf:
        final path = Path();
        path.moveTo(cx, cy - r);
        path.quadraticBezierTo(cx + r, cy, cx, cy + r);
        path.quadraticBezierTo(cx - r, cy, cx, cy - r);
        path.close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint..strokeWidth = 2);
        canvas.drawLine(
            Offset(cx, cy - r * 0.8),
            Offset(cx, cy + r * 0.8),
            paint
              ..strokeWidth = 1
              ..color = color.withOpacity(opacity * 0.6));
        break;

      case _Symbol.mountain:
        final path = Path();
        path.moveTo(cx - r, cy + r * 0.6);
        path.lineTo(cx, cy - r * 0.8);
        path.lineTo(cx + r, cy + r * 0.6);
        path.close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint..strokeWidth = 2);
        final snow = Path();
        snow.moveTo(cx, cy - r * 0.8);
        snow.lineTo(cx - r * 0.25, cy - r * 0.3);
        snow.lineTo(cx + r * 0.25, cy - r * 0.3);
        snow.close();
        canvas.drawPath(
            snow,
            paint
              ..style = PaintingStyle.fill
              ..color = color.withOpacity(opacity * 0.4));
        break;

      case _Symbol.drop:
        final path = Path();
        path.moveTo(cx, cy - r);
        path.cubicTo(cx + r * 0.8, cy - r * 0.2, cx + r * 0.6, cy + r * 0.8, cx,
            cy + r * 0.8);
        path.cubicTo(
            cx - r * 0.6, cy + r * 0.8, cx - r * 0.8, cy - r * 0.2, cx, cy - r);
        canvas.drawPath(path, fill);
        canvas.drawPath(
            path,
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
        break;

      case _Symbol.flame:
        final path = Path();
        path.moveTo(cx, cy - r);
        path.cubicTo(cx + r * 0.8, cy - r * 0.4, cx + r * 0.6, cy + r * 0.4, cx,
            cy + r * 0.8);
        path.cubicTo(cx - r * 0.6, cy + r * 0.4, cx - r * 0.4, cy - r * 0.2,
            cx - r * 0.1, cy - r * 0.4);
        path.cubicTo(cx, cy, cx + r * 0.3, cy - r * 0.5, cx, cy - r);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint..strokeWidth = 2);
        break;

      case _Symbol.crystal:
        final path = Path();
        path.moveTo(cx, cy - r);
        path.lineTo(cx + r * 0.6, cy - r * 0.2);
        path.lineTo(cx + r * 0.6, cy + r * 0.5);
        path.lineTo(cx, cy + r);
        path.lineTo(cx - r * 0.6, cy + r * 0.5);
        path.lineTo(cx - r * 0.6, cy - r * 0.2);
        path.close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, paint..strokeWidth = 1.5);
        canvas.drawLine(Offset(cx - r * 0.6, cy - r * 0.2),
            Offset(cx + r * 0.6, cy - r * 0.2), paint..strokeWidth = 1);
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r),
            paint..color = color.withOpacity(opacity * 0.3));
        break;

      case _Symbol.spiral:
        final path = Path();
        for (double t = 0; t < 4 * pi; t += 0.05) {
          final rad = r * 0.1 + r * 0.22 * (t / (4 * pi));
          final x = cx + cos(t) * rad;
          final y = cy + sin(t) * rad;
          if (t == 0)
            path.moveTo(x, y);
          else
            path.lineTo(x, y);
        }
        canvas.drawPath(
            path,
            paint
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
        break;

      case _Symbol.eye:
        final eyePath = Path();
        eyePath.moveTo(cx - r, cy);
        eyePath.quadraticBezierTo(cx, cy - r * 0.7, cx + r, cy);
        eyePath.quadraticBezierTo(cx, cy + r * 0.7, cx - r, cy);
        canvas.drawPath(eyePath, fill);
        canvas.drawPath(eyePath, paint..strokeWidth = 2);
        canvas.drawCircle(
            Offset(cx, cy),
            r * 0.3,
            paint
              ..style = PaintingStyle.fill
              ..color = color.withOpacity(opacity * 0.7));
        canvas.drawCircle(
            Offset(cx, cy), r * 0.15, paint..color = const Color(0xFF000512));
        break;

      case _Symbol.feather:
        canvas.drawLine(
            Offset(cx - r * 0.6, cy + r * 0.8),
            Offset(cx + r * 0.4, cy - r * 0.8),
            paint
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke
              ..color = color.withOpacity(opacity));
        for (int i = 0; i < 6; i++) {
          final t = i / 6.0;
          final bx = cx - r * 0.6 + (cx + r * 0.4 - (cx - r * 0.6)) * t;
          final by = cy + r * 0.8 + (cy - r * 0.8 - (cy + r * 0.8)) * t;
          canvas.drawLine(
              Offset(bx, by),
              Offset(bx + r * 0.35, by - r * 0.15),
              paint
                ..strokeWidth = 1.2
                ..color = color.withOpacity(opacity * 0.7));
          canvas.drawLine(
              Offset(bx, by),
              Offset(bx - r * 0.3, by + r * 0.1),
              paint
                ..strokeWidth = 1.2
                ..color = color.withOpacity(opacity * 0.5));
        }
        break;
    }
  }

  @override
  bool shouldRepaint(_SymbolPainter old) =>
      old.symbol != symbol || old.opacity != opacity;
}

class _MemoryScreenState extends State<MemoryScreen> {
  static const _gold = Color(0xFFEF9F27);
  static const _goldDim = Color(0xFF7A5010);
  static const _bg = Color(0xFF000512);

  static const _easySymbols = [
    _Symbol.sun,
    _Symbol.moon,
    _Symbol.star,
    _Symbol.wave,
    _Symbol.leaf,
    _Symbol.mountain,
  ];
  static const _mediumSymbols = [
    _Symbol.sun,
    _Symbol.moon,
    _Symbol.star,
    _Symbol.wave,
    _Symbol.leaf,
    _Symbol.mountain,
    _Symbol.drop,
    _Symbol.flame,
    _Symbol.crystal,
    _Symbol.spiral,
  ];
  static const _hardSymbols = [
    _Symbol.sun,
    _Symbol.moon,
    _Symbol.star,
    _Symbol.wave,
    _Symbol.leaf,
    _Symbol.mountain,
    _Symbol.drop,
    _Symbol.flame,
    _Symbol.crystal,
    _Symbol.spiral,
    _Symbol.eye,
    _Symbol.feather,
  ];

  static const _levelLabels = {
    _Level.easy: 'Легко',
    _Level.medium: 'Середньо',
    _Level.hard: 'Складно',
  };
  static const _levelColumns = {
    _Level.easy: 3,
    _Level.medium: 4,
    _Level.hard: 4,
  };

  _Level _level = _Level.easy;
  late List<_Symbol> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  List<int> _selected = [];
  bool _locked = false;
  bool _won = false;
  int _moves = 0;
  int _seconds = 0;
  bool _started = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<_Symbol> get _symbols {
    switch (_level) {
      case _Level.easy:
        return _easySymbols;
      case _Level.medium:
        return _mediumSymbols;
      case _Level.hard:
        return _hardSymbols;
    }
  }

  void _initGame() {
    _timer?.cancel();
    final pairs = [..._symbols, ..._symbols]..shuffle(Random());
    setState(() {
      _cards = pairs;
      _flipped = List.filled(pairs.length, false);
      _matched = List.filled(pairs.length, false);
      _selected = [];
      _locked = false;
      _won = false;
      _moves = 0;
      _seconds = 0;
      _started = false;
    });
  }

  void _startTimer() {
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  String get _timeString {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onTap(int index) {
    if (_locked || _flipped[index] || _matched[index]) return;
    if (!_started) _startTimer();
    HapticFeedback.selectionClick();
    setState(() => _flipped[index] = true);
    _selected.add(index);

    if (_selected.length == 2) {
      _locked = true;
      _moves++;
      final a = _selected[0], b = _selected[1];

      if (_cards[a] == _cards[b]) {
        setState(() {
          _matched[a] = true;
          _matched[b] = true;
        });
        HapticFeedback.mediumImpact();
        _selected = [];
        _locked = false;
        if (_matched.every((m) => m)) {
          _timer?.cancel();
          setState(() => _won = true);
          HapticFeedback.heavyImpact();
        }
      } else {
        Timer(const Duration(milliseconds: 1200), () {
          setState(() {
            _flipped[a] = false;
            _flipped[b] = false;
          });
          _selected = [];
          _locked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Знайди пару',
            style: TextStyle(
                color: _gold, fontSize: 26, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _won ? _buildWin() : _buildGame(),
    );
  }

  Widget _buildWin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(painter: _SymbolPainter(_Symbol.star)),
            ),
            const SizedBox(height: 20),
            const Text('Всі пари знайдено!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _gold, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _resultChip(Icons.touch_app_outlined, '$_moves ходів'),
                const SizedBox(width: 12),
                _resultChip(Icons.timer_outlined, _timeString),
              ],
            ),
            const SizedBox(height: 40),
            _bigButton('НОВА ГРА', _initGame),
          ],
        ),
      ),
    );
  }

  Widget _resultChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: _goldDim, width: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _goldDim, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: _gold, fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        _buildStats(),
        _buildLevelBar(),
        Expanded(child: _buildGrid()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _statChip(Icons.touch_app_outlined, '$_moves ходів'),
          const SizedBox(width: 12),
          _statChip(Icons.timer_outlined, _timeString),
          const Spacer(),
          _statChip(Icons.favorite_outline,
              '${_matched.where((m) => m).length ~/ 2} / ${_symbols.length}'),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: _goldDim, width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _goldDim, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: _gold, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLevelBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: _Level.values.map((lvl) {
          final selected = lvl == _level;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                if (lvl == _level) return;
                setState(() => _level = lvl);
                _initGame();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _gold : Colors.transparent,
                  border: Border.all(
                    color: selected ? _gold : _goldDim,
                    width: selected ? 0 : 0.8,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _levelLabels[lvl]!,
                  style: TextStyle(
                    color: selected ? _bg : _goldDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final cols = _levelColumns[_level]!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: _cards.length,
        itemBuilder: (_, i) => _buildCard(i),
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isMatched
              ? _gold.withOpacity(0.10)
              : isFlipped
                  ? const Color(0xFF0D1B3E)
                  : const Color(0xFF040D20),
          border: Border.all(
            color: isMatched
                ? _gold
                : isFlipped
                    ? _gold.withOpacity(0.8)
                    : _goldDim.withOpacity(0.35),
            width: isMatched ? 1.5 : 0.8,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: isMatched
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomPaint(
                          painter: _SymbolPainter(_cards[index], opacity: 0.5),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Icon(Icons.check_circle_outline,
                          color: _gold, size: 16),
                    ),
                  ],
                )
              : isFlipped
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomPaint(
                        painter: _SymbolPainter(_cards[index]),
                        size: Size.infinite,
                      ),
                    )
                  : CustomPaint(
                      painter: _BackPainter(),
                      size: Size.infinite,
                    ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: _bigButton('НОВА ГРА', _initGame),
    );
  }

  Widget _bigButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _bg,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _BackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7A5010)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final outer = Path()
      ..moveTo(cx, cy * 0.15)
      ..lineTo(size.width * 0.85, cy)
      ..lineTo(cx, cy * 1.85)
      ..lineTo(size.width * 0.15, cy)
      ..close();
    canvas.drawPath(outer, paint);

    final inner = Path()
      ..moveTo(cx, cy * 0.45)
      ..lineTo(size.width * 0.7, cy)
      ..lineTo(cx, cy * 1.55)
      ..lineTo(size.width * 0.3, cy)
      ..close();
    canvas.drawPath(inner, paint..color = const Color(0xFF3A2008));

    canvas.drawCircle(
      Offset(cx, cy),
      3,
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF7A5010),
    );
  }

  @override
  bool shouldRepaint(_BackPainter old) => false;
}
