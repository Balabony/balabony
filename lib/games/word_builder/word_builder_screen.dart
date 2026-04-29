import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordBuilderScreen extends StatefulWidget {
  const WordBuilderScreen({super.key});

  @override
  State<WordBuilderScreen> createState() => _WordBuilderScreenState();
}

class _WordBuilderScreenState extends State<WordBuilderScreen> {
  static const _gold = Color(0xFFEF9F27);
  static const _bg = Color(0xFF000512);

  final String _donor = 'ГОСПОДАРСТВО';
  late List<String> _donorLetters;
  late List<bool> _usedInDonor;
  List<String> _current = [];
  List<String> _found = [];
  String? _message;

  // Простий словник для демо
  final Set<String> _dictionary = {
    'ГОСПОДАР',
    'ГОРА',
    'РОСТ',
    'ТОРГ',
    'СТРЕС',
    'ГОСПОДО',
    'ТАР',
    'РАТ',
    'ГАТ',
    'СОТ',
    'ТОС',
    'РОТ',
    'ОРТ',
    'АРГО',
    'ТРОС',
    'ГОРСТ',
    'СТАР',
    'ТАРА',
    'ГАРТ',
    'ВРАГ',
    'ТРАВ',
    'ОДРА',
    'ДОГА',
    'ГОДА',
    'ОРДА',
  };

  @override
  void initState() {
    super.initState();
    _donorLetters = _donor.split('');
    _usedInDonor = List.filled(_donorLetters.length, false);
  }

  void _tapDonorLetter(int index) {
    if (_usedInDonor[index]) return;
    setState(() {
      _usedInDonor[index] = true;
      _current.add(_donorLetters[index]);
      _message = null;
    });
    HapticFeedback.selectionClick();
  }

  void _tapCurrentLetter(int index) {
    final letter = _current[index];
    // Find first unused donor letter that matches
    for (int i = 0; i < _donorLetters.length; i++) {
      if (_donorLetters[i] == letter && _usedInDonor[i]) {
        setState(() {
          _usedInDonor[i] = false;
          _current.removeAt(index);
          _message = null;
        });
        HapticFeedback.selectionClick();
        return;
      }
    }
  }

  void _check() {
    if (_current.isEmpty) return;
    final word = _current.join();
    if (_found.contains(word)) {
      setState(() => _message = '«$word» вже знайдено');
    } else if (_dictionary.contains(word)) {
      setState(() {
        _found.add(word);
        _message = '✅ «$word» — правильно!';
        _current = [];
        _usedInDonor = List.filled(_donorLetters.length, false);
      });
      HapticFeedback.mediumImpact();
    } else {
      setState(() => _message = '❌ «$word» не знайдено в словнику');
    }
  }

  void _clear() {
    setState(() {
      _current = [];
      _usedInDonor = List.filled(_donorLetters.length, false);
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Словесний конструктор',
            style: TextStyle(
                color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Donor letters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(_donorLetters.length, (i) {
                final used = _usedInDonor[i];
                return GestureDetector(
                  onTap: () => _tapDonorLetter(i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: used ? Colors.grey : _gold, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                      color: used
                          ? Colors.grey.withOpacity(0.1)
                          : _gold.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        _donorLetters[i],
                        style: TextStyle(
                          color: used ? Colors.grey : _gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // Current word slots
          Container(
            height: 60,
            alignment: Alignment.center,
            child: _current.isEmpty
                ? Text('Обери літери зверху',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 16))
                : Wrap(
                    spacing: 6,
                    children: List.generate(_current.length, (i) {
                      return GestureDetector(
                        onTap: () => _tapCurrentLetter(i),
                        child: Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(_current[i],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }),
                  ),
          ),

          const SizedBox(height: 8),

          // Message
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_message!,
                  style: TextStyle(
                    color: _message!.startsWith('✅')
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center),
            ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _clear,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('ОЧИСТИТИ',
                      style: TextStyle(color: Colors.white54, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _check,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('ПЕРЕВІРИТИ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Found words
          if (_found.isNotEmpty) ...[
            Text('Знайдено слів: ${_found.length}',
                style: const TextStyle(color: _gold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _found
                        .map((w) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: _gold.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(w,
                                  style: const TextStyle(
                                      color: _gold, fontSize: 14)),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
