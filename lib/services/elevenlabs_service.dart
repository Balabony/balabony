import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:dio/dio.dart';

class ElevenLabsService {
  final _dio = Dio();

  Future<void> speak(String text, {Function? onComplete}) async {
    try {
      final response = await _dio.post(
        '${html.window.location.origin}/api/tts',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.75,
            'similarity_boost': 0.85,
            'speed': 0.9,
          },
        },
      );

      // Convert bytes to base64 and play via JS
      final bytes = response.data as List<int>;
      final base64 = _bytesToBase64(bytes);

      final completer = Completer<void>();
      js.context['_flutterTtsComplete'] = js.allowInterop(() {
        if (!completer.isCompleted) completer.complete();
      });

      js.context.callMethod('eval', [
        '''
        (function() {
          window.speechSynthesis && window.speechSynthesis.cancel();
          var audio = new Audio("data:audio/mpeg;base64,$base64");
          audio.playbackRate = 1.0;
          audio.onended = function() {
            if (window._flutterTtsComplete) window._flutterTtsComplete();
          };
          audio.onerror = function() {
            if (window._flutterTtsComplete) window._flutterTtsComplete();
          };
          audio.play();
        })();
      '''
      ]);

      await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {},
      );

      onComplete?.call();
    } catch (e) {
      print('ElevenLabs error: $e');
      // Fallback to Web Speech API
      await _fallbackSpeak(text, onComplete: onComplete);
    }
  }

  Future<void> _fallbackSpeak(String text, {Function? onComplete}) async {
    final completer = Completer<void>();
    js.context['_flutterTtsComplete'] = js.allowInterop(() {
      if (!completer.isCompleted) completer.complete();
    });
    final escaped = text.replaceAll("'", "\\'").replaceAll('\n', ' ');
    js.context.callMethod('eval', [
      '''
      (function() {
        var utter = new SpeechSynthesisUtterance('$escaped');
        utter.lang = 'uk-UA';
        utter.rate = 0.9;
        utter.onend = function() { if (window._flutterTtsComplete) window._flutterTtsComplete(); };
        utter.onerror = function() { if (window._flutterTtsComplete) window._flutterTtsComplete(); };
        window.speechSynthesis.speak(utter);
      })();
    '''
    ]);
    await completer.future
        .timeout(const Duration(seconds: 30), onTimeout: () {});
    onComplete?.call();
  }

  String _bytesToBase64(List<int> bytes) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result.write(chars[(b0 >> 2) & 0x3F]);
      result.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      result.write(
          i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      result.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return result.toString();
  }

  Future<void> stop() async {
    js.context.callMethod('eval', [
      '''
      (function() {
        if (window._currentAudio) { window._currentAudio.pause(); }
        window.speechSynthesis && window.speechSynthesis.cancel();
      })();
    '''
    ]);
  }

  Future<void> dispose() async => await stop();
}
