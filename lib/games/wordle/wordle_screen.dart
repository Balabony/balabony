import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

const _words = [
  '�˲�', '����', '����', '����',
  '�����', '̲����', 'ǲ���', 'в���', '����',
  '����', '̲���', '����', '����',
  '�����', '����', '����', '����', '����',
  '����', '������', 'в���', '�����',
  'ϲ���', '�����', '��Ĳ���', '�в�',
];

const _gold = Color(0xFFEF9F27);
const _goldDim = Color(0xFF7A5010);
const _bg = Color(0xFF000512);
const _cardBg = Color(0xFF040D20);

enum _LetterState { empty, typed, correct, present, absent }

class _WordleScreenState extends State<WordleScreen> {
  late String _target;
  late int _wordLen;
  late List<List<String>> _grid;
  late List<List<_LetterState>> _states;
  Map<String, _LetterState> _keyStates = {};
  int _currentRow = 0;
  bool _won = false;
  bool _lost = false;
  String? _message;

  static const _rows = [
    ['�','�','�','�','�','�','�','�','�','�','�'],
    ['�','�','�','�','�','�','�','�','�','�','�'],
    ['�','�','�','�','�','�','�','�','�','�'],
  ];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final list = [..._words]..shuffle();
    _target = list.first;
    _wordLen = _target.length;
    _grid = List.generate(6, (_) => List.filled(_wordLen, ''));
    _states = List.generate(6, (_) => List.filled(_wordLen, _LetterState.empty));
    _keyStates = {};
    _currentRow = 0;
    _won = false;
    _lost = false;
    _message = null;
  }

  int get _filledCols => _grid[_currentRow].where((l) => l.isNotEmpty).length;

  void _onKey(String letter) {
    if (_won || _lost || _filledCols >= _wordLen) return;
    HapticFeedback.selectionClick();
    setState(() {
      final col = _grid[_currentRow].indexWhere((l) => l.isEmpty);
      if (col != -1) _grid[_currentRow][col] = letter;
      _message = null;
    });
  }

  void _onDelete() {
    if (_won || _lost) return;
    HapticFeedback.selectionClick();
    setState(() {
      for (int i = _wordLen - 1; i >= 0; i--) {
        if (_grid[_currentRow][i].isNotEmpty) {
          _grid[_currentRow][i] = '';
          break;
        }
      }
      _message = null;
    });
  }

  void _onEnter() {
    if (_won || _lost) return;
    if (_filledCols < _wordLen) {
      setState(() => _message = '������ �� �����');
      return;
    }
    final guess = _grid[_currentRow].join();
    final result = List.filled(_wordLen, _LetterState.absent);
    final targetChars = _target.split('');
    final guessChars = guess.split('');

    for (int i = 0; i < _wordLen; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = _LetterState.correct;
        targetChars[i] = '';
        guessChars[i] = '';
      }
    }
    for (int i = 0; i < _wordLen; i++) {
      if (guessChars[i].isEmpty) continue;
      final j = targetChars.indexOf(guessChars[i]);
      if (j != -1) {
        result[i] = _LetterState.present;
        targetChars[j] = '';
      }
    }

    setState(() {
      _states[_currentRow] = result;
      for (int i = 0; i < _wordLen; i++) {
        final letter = _grid[_currentRow][i];
        final prev = _keyStates[letter] ?? _LetterState.empty;
        if (result[i] == _LetterState.correct ||
            (result[i] == _LetterState.present && prev != _LetterState.correct) ||
            (result[i] == _LetterState.absent && prev == _LetterState.empty)) {
          _keyStates[letter] = result[i];
        }
      }
      if (guess == _target) {
        _won = true;
        _message = '³���!';
      } else if (_currentRow == 5) {
        _lost = true;
        _message = '�����: $_target';
      } else {
        _currentRow++;
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('������ �����',
            style: TextStyle(color: _gold, fontSize: 26, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (_message != null) _buildMessage(),
          const SizedBox(height: 12),
          Expanded(child: _buildGrid()),
          _buildKeyboard(),
          if (_won || _lost) ...[
            const SizedBox(height: 12),
            _buildNewGame(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    final isGood = _won;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isGood ? _gold.withOpacity(0.15) : _cardBg,
        border: Border.all(color: isGood ? _gold : _goldDim, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(_message!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isGood ? _gold : Colors.white70,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _buildGrid() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_wordLen, (col) {
                  final letter = _grid[row][col];
                  final state = _states[row][col];
                  return _buildCell(letter, state);
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(String letter, _LetterState state) {
    Color bg = _cardBg;
    Color border = _goldDim.withOpacity(0.3);
    Color textColor = Colors.white;

    switch (state) {
      case _LetterState.correct:
        bg = _gold; border = _gold; textColor = _bg; break;
      case _LetterState.present:
        bg = _goldDim; border = _goldDim; textColor = Colors.white; break;
      case _LetterState.absent:
        bg = const Color(0xFF1A1A2E); border = Colors.white12; textColor = Colors.white38; break;
      default: break;
    }
    if (letter.isNotEmpty && state == _LetterState.empty) {
      border = _gold.withOpacity(0.6);
    }

    return Container(
      width: 52, height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(letter,
            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ..._rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((k) => _buildKey(k)).toList(),
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionKey('ENTER', _onEnter),
              const SizedBox(width: 6),
              _buildActionKey('?', _onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String letter) {
    final state = _keyStates[letter] ?? _LetterState.empty;
    Color bg = const Color(0xFF0D1B3E);
    Color textColor = Colors.white70;
    switch (state) {
      case _LetterState.correct: bg = _gold; textColor = _bg; break;
      case _LetterState.present: bg = _goldDim; textColor = Colors.white; break;
      case _LetterState.absent: bg = const Color(0xFF1A1A2E); textColor = Colors.white24; break;
      default: break;
    }
    return GestureDetector(
      onTap: () => _onKey(letter),
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 34, height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _goldDim.withOpacity(0.3), width: 0.5),
        ),
        child: Center(
          child: Text(letter,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildActionKey(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: label == 'ENTER' ? _gold : const Color(0xFF0D1B3E),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: TextStyle(
              color: label == 'ENTER' ? _bg : Colors.white70,
              fontSize: 14, fontWeight: FontWeight.w800,
            )),
      ),
    );
  }

  Widget _buildNewGame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => setState(_newGame),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _gold, borderRadius: BorderRadius.circular(14),
          ),
          child: const Text('���� ���',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _bg, fontSize: 18,
                fontWeight: FontWeight.w800, letterSpacing: 1.5,
              )),
        ),
      ),
    );
  }
}