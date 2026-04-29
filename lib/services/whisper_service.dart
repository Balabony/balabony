import 'dart:async';
import 'dart:js' as js;

class WhisperService {
  Future<bool> hasPermission() async => true;

  Future<void> startRecording() async {
    js.context.callMethod('eval', [
      '''
      (function() {
        window._recognizing = true;
        window._transcript = "";
        var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (!SpeechRecognition) { window._recognizing = false; return; }
        window._recognition = new SpeechRecognition();
        window._recognition.lang = "uk-UA";
        window._recognition.continuous = true;
        window._recognition.interimResults = true;
        window._recognition.onresult = function(e) {
          var t = "";
          for (var i = 0; i < e.results.length; i++) {
            t += e.results[i][0].transcript;
          }
          window._transcript = t;
        };
        window._recognition.onerror = function(e) { window._recognizing = false; };
        window._recognition.onend = function() { window._recognizing = false; };
        window._recognition.start();
      })();
    '''
    ]);
  }

  Future<String?> stopAndTranscribe() async {
    js.context.callMethod('eval', [
      '''
      (function() {
        if (window._recognition) { window._recognition.stop(); }
      })();
    '''
    ]);
    await Future.delayed(const Duration(milliseconds: 500));
    final transcript = js.context['_transcript'] as String?;
    return (transcript != null && transcript.isNotEmpty) ? transcript : null;
  }

  Future<void> dispose() async {
    js.context.callMethod('eval', [
      '''
      (function() {
        if (window._recognition) { window._recognition.stop(); }
      })();
    '''
    ]);
  }
}
