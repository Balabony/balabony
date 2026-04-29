import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ball_state.dart';

const String _systemPrompt = '''
Ти — Балабон, теплий і терплячий голосовий помічник для людей старшого віку.

ХАРАКТЕР:
- Говориш як добрий сусід або онук — просто, тепло, без поспіху
- Ніколи не згадуєш вік, обмеження або труднощі користувача
- Завжди позитивний, але не нав'язливий
- Якщо не зрозумів — перепитуєш спокійно, без "помилки"

МОВА:
- Короткі речення — максимум 15 слів
- Жодних технічних термінів
- Звертаєшся на "Ви" з теплотою
- Уникаєш слів: "натисніть", "меню", "налаштування", "інтерфейс"

ВІДПОВІДІ:
- Максимум 3 речення за раз
- Після кожної відповіді — жди реакції
- Не перебивай навіть якщо пауза довга

ЗАБОРОНЕНІ ФРАЗИ:
- "Вибачте за незручності"
- "Технічна помилка"
- "Натисніть кнопку"
- "Ви зробили помилку"
- будь-що що натякає на складність

ПРІОРИТЕТИ ДІЙ:
1. Зателефонувати рідним
2. Увімкнути аудіоісторію
3. Увімкнути музику
4. Нагадування про ліки
5. Просто поговорити
''';

class GptService {
  final _dio = Dio();
  final List<ConversationMessage> _history = [];

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Add system prompt on init
  GptService() {
    _history.add(ConversationMessage(
      role: 'system',
      content: _systemPrompt,
      timestamp: DateTime.now(),
    ));
  }

  Future<String> sendMessage(String userMessage) async {
    // Add user message to history
    _history.add(ConversationMessage(
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));

    // Keep only last 10 minutes of conversation
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));
    final recentMessages = _history.where((m) =>
        m.role == 'system' || m.timestamp.isAfter(cutoff)).toList();

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'max_tokens': 150,
          'temperature': 0.7,
          'messages': recentMessages.map((m) => m.toMap()).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'] as String;

        // Add assistant response to history
        _history.add(ConversationMessage(
          role: 'assistant',
          content: content,
          timestamp: DateTime.now(),
        ));

        return content.trim();
      }
    } catch (e) {
      print('GPT error: $e');
    }

    return 'Вибачте, не почув добре. Скажіть ще раз, будь ласка?';
  }

  String getFirstGreeting() {
    return 'Привіт! Я Балабон. Дуже радий познайомитись. Скажіть просто: Балабоне — і я одразу слухаю.';
  }

  String getSilenceResponse() {
    return 'Я тут. Нікуди не поспішаю. Скажіть коли будете готові.';
  }
}
