import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class ProverbsScreen extends StatefulWidget {
  const ProverbsScreen({super.key});

  @override
  State<ProverbsScreen> createState() => _ProverbsScreenState();
}

class _ProverbsScreenState extends State<ProverbsScreen> {
  static const _gold = Color(0xFFEF9F27);
  static const _bg = Color(0xFF000512);

  final List<Map<String, dynamic>> _proverbs = [
    {
      'start': 'Без труда не виловиш',
      'end': 'і рибку зі ставка',
      'wrong': ['і пташку з гнізда', 'і гриб з лісу']
    },
    {
      'start': 'Друзі пізнаються',
      'end': 'у біді',
      'wrong': ['на весіллі', 'за грошима']
    },
    {
      'start': 'Не кажи «гоп»',
      'end': 'поки не перескочиш',
      'wrong': ['поки не впадеш', 'поки не втомишся']
    },
    {
      'start': 'Яблуко від яблуні',
      'end': 'недалеко падає',
      'wrong': ['далеко котиться', 'швидко гниє']
    },
    {
      'start': 'Краще пізно',
      'end': 'ніж ніколи',
      'wrong': ['ніж зарано', 'ніж завжди']
    },
    {
      'start': 'Слово — не горобець',
      'end': 'вилетить — не спіймаєш',
      'wrong': ['не впіймаєш у клітку', 'не посадиш на гілку']
    },
    {
      'start': 'Де багато слів',
      'end': 'там мало діла',
      'wrong': ['там багато радості', 'там мало сліз']
    },
    {
      'start': 'Хто рано встає',
      'end': 'тому Бог дає',
      'wrong': ['той швидко старіє', 'той більше спить']
    },
    {
      'start': 'Не май сто рублів',
      'end': 'а май сто друзів',
      'wrong': ['а май сто книг', 'а май сто корів']
    },
    {
      'start': 'У чужому оці',
      'end': 'скалку бачить, а у своєму й колоди не помічає',
      'wrong': ['сльозу бачить', 'радість бачить']
    },
    {
      'start': 'Тихіше їдеш',
      'end': 'далі будеш',
      'wrong': ['більше спиш', 'менше знаєш']
    },
    {
      'start': 'Вовків боятися',
      'end': 'в ліс не ходити',
      'wrong': ['у поле не йти', 'вдома сидіти']
    },
    {
      'start': 'Що посієш',
      'end': 'те й пожнеш',
      'wrong': ['те й з\'їси', 'те й продаси']
    },
    {
      'start': 'Своя хата',
      'end': 'своя правда',
      'wrong': ['своя земля', 'свої люди']
    },
    {
      'start': 'Правда очі',
      'end': 'коле',
      'wrong': ['сліпить', 'лікує']
    },
    {
      'start': 'Гарна та пташка',
      'end': 'що своє гніздо береже',
      'wrong': ['що гарно співає', 'що високо літає']
    },
    {
      'start': 'Козак без коня',
      'end': 'що солдат без рушниці',
      'wrong': ['що птах без крил', 'що риба без води']
    },
    {
      'start': 'Не копай іншому яму',
      'end': 'сам у неї впадеш',
      'wrong': ['бо втомишся', 'бо земля тверда']
    },
    {
      'start': 'Терпи козаче',
      'end': 'отаманом будеш',
      'wrong': ['силу матимеш', 'поважатимуть тебе']
    },
    {
      'start': 'Хліб — усьому',
      'end': 'голова',
      'wrong': ['основа', 'початок']
    },
    {
      'start': 'Рідна земля',
      'end': 'і в жмені мила',
      'wrong': ['найкраща', 'завжди чекає']
    },
    {
      'start': 'Не все те золото',
      'end': 'що блищить',
      'wrong': ['що дороге', 'що жовте']
    },
    {
      'start': 'Мудрий не той хто багато знає',
      'end': 'а той хто знає потрібне',
      'wrong': ['а той хто мовчить', 'а той хто вчить інших']
    },
    {
      'start': 'Добре там',
      'end': 'де нас нема',
      'wrong': ['де сонце світить', 'де тихо й спокійно']
    },
    {
      'start': 'Гей, наливайте повнії чари',
      'end': 'хай буде весело нам',
      'wrong': ['хай буде смачно нам', 'хай буде тепло нам']
    },
  ];

  late List<Map<String, dynamic>> _shuffled;
  int _current = 0;
  int _score = 0;
  final int _total = 10;
  String? _selected;
  bool? _correct;
  bool _finished = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _shuffled = List.from(_proverbs)..shuffle();
    _shuffled = _shuffled.take(_total).toList();
    _current = 0;
    _score = 0;
    _selected = null;
    _correct = null;
    _finished = false;
    _buildOptions();
  }

  void _buildOptions() {
    final p = _shuffled[_current];
    _options = [p['end'] as String, ...List<String>.from(p['wrong'])]
      ..shuffle();
  }

  void _answer(String option) {
    if (_selected != null) return;
    final correct = option == _shuffled[_current]['end'];
    setState(() {
      _selected = option;
      _correct = correct;
      if (correct) _score++;
    });
    HapticFeedback.mediumImpact();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_current + 1 >= _total) {
        setState(() => _finished = true);
      } else {
        setState(() {
          _current++;
          _selected = null;
          _correct = null;
          _buildOptions();
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
        title: const Text('Продовж прислів\'я',
            style: TextStyle(
                color: _gold, fontSize: 22, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: _gold),
      ),
      body: _finished ? _buildResult() : _buildGame(),
    );
  }

  Widget _buildGame() {
    final p = _shuffled[_current];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
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
          const SizedBox(height: 40),

          // Proverb start
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '«${p['start']}...»',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('Оберіть правильне закінчення:',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const SizedBox(height: 16),

          // Options
          ...(_options.map((opt) {
            Color borderColor = _gold.withOpacity(0.4);
            Color bgColor = Colors.transparent;
            Color textColor = Colors.white;

            if (_selected != null) {
              if (opt == _shuffled[_current]['end']) {
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
              onTap: () => _answer(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '...${opt}',
                  style: TextStyle(color: textColor, fontSize: 18, height: 1.4),
                ),
              ),
            );
          })),
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
        ? 'Чудова пам\'ять!'
        : percent >= 60
            ? 'Добрий результат!'
            : 'Тренуйтесь далі!';

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
