import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

const _gold = Color(0xFFEF9F27);
const _goldDim = Color(0xFF7A5010);
const _bg = Color(0xFF000512);
const _cardBg = Color(0xFF040D20);

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const int _size = 3;
  late List<int> _tiles;
  int _moves = 0;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _tiles = List.generate(_size * _size, (i) => i);
    // Перемішуємо
    final rng = Random();
    for (int i = _tiles.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = _tiles[i];
      _tiles[i] = _tiles[j];
      _tiles[j] = tmp;
    }
    // Переконуємось що розв'язок є
    if (!_isSolvable()) {
      final tmp = _tiles[0];
      _tiles[0] = _tiles[1];
      _tiles[1] = tmp;
    }
    _moves = 0;
    _won = false;
  }

  bool _isSolvable() {
    int inversions = 0;
    final flat = _tiles.where((t) => t != 0).toList();
    for (int i = 0; i < flat.length; i++) {
      for (int j = i + 1; j < flat.length; j++) {
        if (flat[i] > flat[j]) inversions++;
      }
    }
    return inversions % 2 == 0;
  }

  void _tap(int index) {
    if (_won) return;
    final empty = _tiles.indexOf(0);
    final row = index ~/ _size;
    final col = index % _size;
    final eRow = empty ~/ _size;
    final eCol = empty % _size;

    if ((row == eRow && (col - eCol).abs() == 1) ||
        (col == eCol && (row - eRow).abs() == 1)) {
      HapticFeedback.selectionClick();
      setState(() {
        _tiles[empty] = _tiles[index];
        _tiles[index] = 0;
        _moves++;
        _won = _tiles.asMap().entries.every((e) => e.key == e.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Пазл',
            style: TextStyle(
                color: _gold, fontSize: 26, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$_moves ходів',
                  style: const TextStyle(
                      color: _gold, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          if (_won)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                border: Border.all(color: _gold),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '🎉 Вітаємо! $_moves ходів',
                style: const TextStyle(
                    color: _gold, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const Spacer(),
          _buildGrid(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => setState(() => _newGame()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'НОВА ГРА',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _bg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _size,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _size * _size,
          itemBuilder: (_, i) {
            final val = _tiles[i];
            if (val == 0) {
              return Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }
            final isCorrect = val == i;
            return GestureDetector(
              onTap: () => _tap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isCorrect ? _gold.withOpacity(0.2) : _cardBg,
                  border: Border.all(
                    color: isCorrect ? _gold : _goldDim,
                    width: isCorrect ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: TextStyle(
                      color: isCorrect ? _gold : Colors.white70,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
