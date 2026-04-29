import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ball_state.dart';
import '../services/whisper_service.dart';
import '../services/elevenlabs_service.dart';
import '../services/gpt_service.dart';

// ── Providers ──

final whisperProvider = Provider((_) => WhisperService());
final elevenLabsProvider = Provider((_) => ElevenLabsService());
final gptProvider = Provider((_) => GptService());

final ballStateProvider =
    StateNotifierProvider<BallStateNotifier, BallStateData>(
  (ref) => BallStateNotifier(
    ref.watch(whisperProvider),
    ref.watch(elevenLabsProvider),
    ref.watch(gptProvider),
  ),
);

// ── State Data ──

class BallStateData {
  final BallState state;
  final String displayText;
  final double amplitude; // 0.0 - 1.0
  final bool isFirstLaunch;

  const BallStateData({
    this.state = BallState.idle,
    this.displayText = '',
    this.amplitude = 0.0,
    this.isFirstLaunch = true,
  });

  BallStateData copyWith({
    BallState? state,
    String? displayText,
    double? amplitude,
    bool? isFirstLaunch,
  }) =>
      BallStateData(
        state: state ?? this.state,
        displayText: displayText ?? this.displayText,
        amplitude: amplitude ?? this.amplitude,
        isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      );
}

// ── Notifier ──

class BallStateNotifier extends StateNotifier<BallStateData> {
  final WhisperService _whisper;
  final ElevenLabsService _elevenLabs;
  final GptService _gpt;

  Timer? _silenceTimer;
  Timer? _amplitudeTimer;
  bool _isProcessing = false;

  BallStateNotifier(this._whisper, this._elevenLabs, this._gpt)
      : super(const BallStateData());

  // ── Public Methods ──

  Future<void> initialize() async {
    // Check microphone permission
    final hasPermission = await _whisper.hasPermission();
    if (!hasPermission) return;

    // First greeting
    await _speak(_gpt.getFirstGreeting());
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> onTap() async {
    if (_isProcessing) return;

    if (state.state == BallState.idle) {
      await _startListening();
    } else if (state.state == BallState.listening) {
      await _stopListeningAndProcess();
    }
  }

  // ── Private Methods ──

  Future<void> _startListening() async {
    _isProcessing = true;
    _cancelSilenceTimer();

    await _whisper.startRecording();
    _startAmplitudeSimulation();

    state = state.copyWith(
      state: BallState.listening,
      displayText: 'Слухаю...',
    );

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start silence timer — 8 seconds
    _silenceTimer = Timer(const Duration(seconds: 8), () async {
      if (state.state == BallState.listening) {
        await _stopListeningAndProcess(silent: true);
      }
    });

    _isProcessing = false;
  }

  Future<void> _stopListeningAndProcess({bool silent = false}) async {
    if (_isProcessing) return;
    _isProcessing = true;
    _cancelSilenceTimer();
    _stopAmplitudeSimulation();

    // Thinking state
    state = state.copyWith(
      state: BallState.thinking,
      displayText: 'Думаю...',
      amplitude: 0.0,
    );

    if (silent) {
      // Silence response
      await _speak(_gpt.getSilenceResponse());
    } else {
      // Transcribe audio
      final transcription = await _whisper.stopAndTranscribe();

      if (transcription != null && transcription.isNotEmpty) {
        // Haptic on successful recognition
        HapticFeedback.mediumImpact();

        // Get GPT response
        final response = await _gpt.sendMessage(transcription);
        await _speak(response);
      } else {
        await _speak('Вибачте, не почув добре. Скажіть ще раз, будь ласка?');
      }
    }

    _isProcessing = false;
  }

  Future<void> _speak(String text) async {
    state = state.copyWith(
      state: BallState.speaking,
      displayText: text,
    );

    await _elevenLabs.speak(text, onComplete: () {
      if (mounted) {
        state = state.copyWith(
          state: BallState.idle,
          displayText: '',
          amplitude: 0.0,
        );
        // Auto-start listening after speaking
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && state.state == BallState.idle) {
            _startListening();
          }
        });
      }
    });
  }

  void _startAmplitudeSimulation() {
    // In real app, use microphone amplitude stream
    // This simulates amplitude for UI demo
    double amp = 0.0;
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (state.state == BallState.listening) {
          // Simulate breathing amplitude
          amp = (amp + 0.1) % 1.0;
          state = state.copyWith(amplitude: amp);
        }
      },
    );
  }

  void _stopAmplitudeSimulation() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
  }

  void _cancelSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }

  @override
  void dispose() {
    _cancelSilenceTimer();
    _stopAmplitudeSimulation();
    _whisper.dispose();
    _elevenLabs.dispose();
    super.dispose();
  }
}
