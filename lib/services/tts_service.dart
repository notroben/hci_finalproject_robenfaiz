import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-US"); // Default locale
      await _flutterTts.setSpeechRate(0.5); // Default speed rate
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  Future<void> speak(String text, {double rate = 0.5}) async {
    if (!_isInitialized) await _initTts();
    try {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.speak(text);
    } catch (e) {
      // TTS error fallback
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      // Fail silently
    }
  }
}
