import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({super.key});

  @override
  State<OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> {
  static const _gold = Color(0xFFEF9F27);
  static const _bg = Color(0xFF000512);

  final List<Map<String, dynamic>> _questions = [
    {
      'words': ['Калина', 'Верба', 'Дуб', 'Соловей'],
      'odd': 'Соловей',
      'hint': 'Соловей — птах, решта — дерева'
    },
    {
      'words': ['Київ', 'Львів', 'Дніпро', 'Дунай'],
      'odd': 'Дунай',
      'hint': 'Дунай — ріка, решта — міста'
    },
    {
      'words': ['Борщ', 'Вареники', 'Галушки', 'Бандура'],
      'odd': 'Бандура',
      'hint': 'Бандура — інструмент, решта — страви'
    },
    {
      'words': ['Троянда', 'Ромашка', 'Мак', 'Береза'],
      'odd': 'Береза',
      'hint': 'Береза — дерево, решта — квіти'
    },
    {
      'words': ['Корова', 'Кінь', 'Свиня', 'Орел'],
      'odd': 'Орел',
      'hint': 'Орел — птах, решта — свійські тварини'
    },
    {
      'words': ['Понеділок', 'Вівторок', 'Травень', 'Середа'],
      'odd': 'Травень',
      'hint': 'Травень — місяць, решта — дні тижня'
    },
    {
      'words': ['Скрипка', 'Сопілка', 'Бандура', 'Барабан'],
      'odd': 'Барабан',
      'hint': 'Барабан — ударний, решта — струнні/духові'
    },
    {
      'words': ['Чорне', 'Азовське', 'Дніпро', 'Балтійське'],
      'odd': 'Дніпро',
      'hint': 'Дніпро — ріка, решта — моря'
    },
    {
      'words': ['Шевченко', 'Франко', 'Леся Українка', 'Мазепа'],
      'odd': 'Мазепа',
      'hint': 'Мазепа — гетьман, решта — письменники'
    },
    {
      'words': ['Яблуко', 'Груша', 'Слива', 'Огірок'],
      'odd': 'Огірок',
      'hint': 'Огірок — овоч, решта — фрукти'
    },
    {
      'words': ['Лелека', 'Ластівка', 'Зозуля', 'Заєць'],
      'odd': 'Заєць',
      'hint': 'Заєць — тварина, решта — птахи'
    },
    {
      'words': ['Зима', 'Весна', 'Вересень', 'Літо'],
      'odd': 'Вересень',
      'hint': 'Вересень — місяць, решта — пори року'
    },
    {
      'words': ['Вишиванка', 'Кобза', 'Рушник', 'Писанка'],
      'odd': 'Кобза',
      'hint': 'Кобза — інструмент, решта — символи'
    },
    {
      'words': ['Суниця', 'Малина', 'Смородина', 'Кропива'],
      'odd': 'Кропива',
      'hint': 'Кропива — трава, решта — ягоди'
    },
    {
      'words': ['Карпати', 'Говерла', 'Синевир', 'Дніпро'],
      'odd': 'Дніпро',
      'hint': 'Дніпро — ріка, решта — гори/озеро'
    },
  ];

  late List<Map<String, dynamic>> _shuffled;
  int _current = 0;
  int _score = 0;
  final int _total = 10;
  String? _selected;
  bool? _correct;
  bool _finished = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _shuffled = List.from(_questions)..shuffle();
    _shuffled = _shuffled.take(_total).toList();
    _current = 0;
    _score = 0;
    _selected = null;
    _correct = null;
    _finished = false;
    _showHint = false;
  }

  void _answer(String word) {
    if (_selected != null) return;
    final correct = word == _shuffled[_current]['odd'];
    setState(() {
      _selected = word;
      _correct = correct;
      _showHint = true;
      if (correct) _score++;
    });
    HapticFeedback.mediumImpact();

    Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_current + 1 >= _total) {
        setState(() => _finished = true);
      } else {
        setState(() {
          _current++;
          _selected = null;
          _correct = null;
          _showHint = false;
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
        title: const Text('Знайди зайве',
            style: TextStyle(
                color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _finished ? _buildResult() : _buildGame(),
    );
  }

  Widget _buildGame() {
    final q = _shuffled[_current];
    final words = List<String>.from(q['words'])..shuffle();

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
          const SizedBox(height: 48),
          const Text('Яке слово зайве?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300)),
          const SizedBox(height: 8),
          Text('Натисніть на слово, яке не підходить до решти',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 14)),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: words.map((word) {
              Color borderColor = _gold.withOpacity(0.5);
              Color bgColor = Colors.transparent;
              Color textColor = Colors.white;

              if (_selected != null) {
                if (word == q['odd']) {
                  borderColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.15);
                  textColor = Colors.green;
                } else if (word == _selected && !_correct!) {
                  borderColor = Colors.red;
                  bgColor = Colors.red.withOpacity(0.15);
                  textColor = Colors.red;
                } else {
                  borderColor = Colors.white12;
                  textColor = Colors.white38;
                }
              }

              return GestureDetector(
                onTap: () => _answer(word),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(word,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          if (_showHint)
            AnimatedOpacity(
              opacity: _showHint ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _correct! ? Colors.green : Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  q['hint'],
                  style: TextStyle(
                      color: _correct! ? Colors.green : Colors.red,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final percent = (_score / _total * 100).round();
    String emoji = percent >= 80
        ? '🏆'
        : percent >= 60
            ? '👏'
            : '💪';
    String message = percent >= 80
        ? 'Блискуче!'
        : percent >= 60
            ? 'Молодець!'
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
