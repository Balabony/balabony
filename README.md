# Balabony AI — Flutter MVP

Голосовий компаньйон для людей старшого віку.

## Швидкий старт

### 1. Встановити Flutter
```bash
# https://flutter.dev/docs/get-started/install
flutter --version  # потрібно 3.x+
```

### 2. Клонувати та встановити залежності
```bash
cd balabony_ai
flutter pub get
```

### 3. Додати API ключі
Відкрийте файл `.env` і замініть:
```
OPENAI_API_KEY=sk-ваш_ключ_тут
ELEVENLABS_API_KEY=ваш_ключ_тут
ELEVENLABS_VOICE_ID=ваш_voice_id_тут
```

**Де взяти ключі:**
- OpenAI: https://platform.openai.com/api-keys
- ElevenLabs: https://elevenlabs.io → Profile → API Key
- Voice ID: ElevenLabs → Voice Library → оберіть голос → скопіюйте ID

### 4. Запустити
```bash
# На підключеному Android/iOS пристрої:
flutter run

# Або на емуляторі:
flutter run -d emulator-5554
```

## Структура проєкту

```
lib/
├── main.dart                    # Точка входу
├── models/
│   └── ball_state.dart          # Стани сфери та моделі
├── providers/
│   └── ball_provider.dart       # Riverpod state management
├── screens/
│   └── balabony_screen.dart     # Головний екран
├── services/
│   ├── whisper_service.dart     # OpenAI Whisper STT
│   ├── elevenlabs_service.dart  # ElevenLabs TTS
│   └── gpt_service.dart         # GPT-4o-mini логіка
└── widgets/
    └── balabony_sphere.dart     # CustomPainter сфера
```

## Стани сфери

| Стан | Колір | Анімація |
|------|-------|----------|
| IDLE | #1a237e (темно-синій) | Пульсація 0.8 сек |
| LISTENING | #ef9f27 (золото) | Реакція на мікрофон |
| THINKING | #7b1fa2 (фіолет) | Обертання + "Думаю..." |
| SPEAKING | #ef9f27 (золото) | Активне світіння |

## API Параметри

### Whisper STT
- model: `whisper-1`
- language: `uk`
- temperature: `0`

### ElevenLabs TTS
- model: `eleven_turbo_v2_5`
- speed: `0.9` (10% повільніше для літніх)
- stability: `0.75`

### GPT-4o-mini
- max_tokens: `150` (короткі відповіді)
- context: останні 10 хвилин діалогу

## Логіка тиші
Якщо користувач мовчить **8 секунд** — Балабон каже:
> "Я тут. Нікуди не поспішаю. Скажіть коли будете готові."

## Haptic Feedback
`HapticFeedback.mediumImpact()` при кожному успішному розпізнаванні.

## iOS Налаштування
Додайте до `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Балабону потрібен мікрофон щоб чути Вас</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Для розпізнавання Вашого голосу</string>
```

## Контакт
nazar@balabony.net | balabony.com
