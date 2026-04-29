import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  static const _gold = Color(0xFFEF9F27);
  static const _bg = Color(0xFF000512);
  final _rng = Random();

  int _a = 0, _b = 0;
  String _op = '+';
  int _answer = 0;
  late List<int> _options;
  int _score = 0;
  int _current = 0;
  final int _total = 10;
  int? _selected;
  bool? _correct;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _score = 0;
    _current = 0;
    _selected = null;
    _correct = null;
    _finished = false;
    _nextQuestion();
  }

  void _nextQuestion() {
    final ops = ['+', '-', '+', '+'];
    _op = ops[_rng.nextInt(ops.length)];

    if (_op == '+') {
      _a = _rng.nextInt(40) + 5;
      _b = _rng.nextInt(40) + 5;
      _answer = _a + _b;
    } else {
      _a = _rng.nextInt(40) + 20;
      _b = _rng.nextInt(_a - 1) + 1;
      _answer = _a - _b;
    }

    final wrongs = <int>{};
    while (wrongs.length < 3) {
      final w = _answer + _rng.nextInt(11) - 5;
      if (w != _answer && w > 0) wrongs.add(w);
    }
    _options = [_answer, ...wrongs]..shuffle();
    _selected = null;
    _correct = null;
  }

  void _pick(int val) {
    if (_selected != null) return;
    final correct = val == _answer;
    setState(() {
      _selected = val;
      _correct = correct;
      if (correct) _score++;
    });
    HapticFeedback.mediumImpact();

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_current + 1 >= _total) {
        setState(() => _finished = true);
      } else {
        setState(() {
          _current++;
          _nextQuestion();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Лічилка',
            style: TextStyle(
                color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _finished ? _buildResult() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Text('${_current + 1} / $_total',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 14)),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_current + 1) / _total,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(_gold),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text('⭐ $_score',
                  style: const TextStyle(
                      color: _gold, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 60),
          Text('Скільки буде?',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 16)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_a  $_op  $_b  =  ?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 48),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: _options.map((opt) {
              Color borderColor = _gold.withOpacity(0.5);
              Color bgColor = Colors.transparent;
              Color textColor = Colors.white;

              if (_selected != null) {
                if (opt == _answer) {
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.15);
                  textColor = Colors.green;
                } else if (opt == _selected && !_correct!) {
                  borderColor = Colors.red;
                  bgColor = Colors.red.withOpacity(0.15);
                  textColor = Colors.red;
                }
              }

              return GestureDetector(
                onTap: () => _pick(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('$opt',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percent = (_score / _total * 100).round();
    String emoji = percent >= 80
        ? '🧮'
        : percent >= 60
            ? '👏'
            : '💪';
    String message = percent >= 80
        ? 'Острий розум!'
        : percent >= 60
            ? 'Добре!'
            : 'Тренуйтесь!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(message,
                style: const TextStyle(
                    color: _gold, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('$_score з $_total правильних',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 18)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => setState(_initGame),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Грати ще',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
