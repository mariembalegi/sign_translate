import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

import 'storage_service.dart';

class SignLanguageService {
  static const Map<String, String> _localWordVideos = {
    '3aslema': 'videos/3aslema.mp4',
    'barnamjek': 'videos/barnamjek.mp4',
    'bou': 'videos/bou.mp4',
  };

  static String _defaultBaseUrl() {
    // Android emulator  → 10.0.2.2
    // iOS simulator     → localhost
    // Physical device   → your computer's LAN IP (configurable in app storage)
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  String get baseUrl {
    final stored = StorageService().getServerUrl().trim();
    if (stored.isNotEmpty) return stored;
    return _defaultBaseUrl();
  }

  static final SignLanguageService _instance = SignLanguageService._internal();

  factory SignLanguageService() => _instance;

  SignLanguageService._internal();

  // ── Health check ────────────────────────────
  Future<HealthCheckResponse> getHealthStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return HealthCheckResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Health check failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // ── Predict from JPEG bytes ──────────────────
  Future<PredictionResponse> predictFromImage(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict/image'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: 'frame.jpg'),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 10));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      return PredictionResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Prediction failed: ${response.statusCode}');
  }

  // ── Reset server-side sequence buffer ────────
  Future<void> resetSession() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/reset'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  // ── Text → Sign video ────────────────────────
  Uri _textToSignUri(String text) {
    return Uri.parse('$baseUrl/text_to_sign').replace(
      queryParameters: {'text': text},
    );
  }

  /// Retourne l'URL (GET) que `video_player` va streamer.
  /// On évite `HEAD` car beaucoup de serveurs ne le supportent pas.
  Future<String> textToSign(String text) async {
    final uri = _textToSignUri(text);
    // Pré-check léger via GET avec Range pour éviter de télécharger toute la vidéo.
    final response = await http.get(
      uri,
      headers: const {'Range': 'bytes=0-1'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 206) {
      return uri.toString();
    }
    throw Exception('Impossible de générer la vidéo (HTTP ${response.statusCode}). Vérifie l’URL du serveur.');
  }

  /// Split simple du texte en tokens (mots), utile si le backend ne gère
  /// qu’un seul mot par requête.
  List<String> tokenizeText(String text) {
    final cleaned = text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s']+", unicode: true), ' ');
    return cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  Future<List<String>> textToSignSequence(String text) async {
    final tokens = tokenizeText(text);
    if (tokens.isEmpty) return [];

    final urls = <String>[];
    for (final token in tokens) {
      final localPath = _localWordVideos[token];
      if (localPath != null) {
        urls.add('asset://$localPath');
        continue;
      }
      urls.add(await textToSign(token));
    }
    return urls;
  }

  // ── Available sign classes ───────────────────
  Future<ClassesResponse> getAvailableClasses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/models/classes'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return ClassesResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to get classes: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class HealthCheckResponse {
  final String status;
  final bool modelLoaded;
  final int numClasses;
  
  HealthCheckResponse({
    required this.status,
    required this.modelLoaded,
    required this.numClasses,
  });
  
  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      status: json['status'] ?? 'unknown',
      modelLoaded: json['model_loaded'] ?? false,
      numClasses: json['num_classes'] ?? 0,
    );
  }
}

class PredictionResponse {
  final String gesture;
  final double confidence;
  final bool handsDetected;
  final int progress;
  final String sentence;
  final bool newWord;
  final String timestamp;

  PredictionResponse({
    required this.gesture,
    required this.confidence,
    required this.handsDetected,
    required this.progress,
    required this.sentence,
    required this.newWord,
    required this.timestamp,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      gesture: json['gesture'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      handsDetected: json['hands_detected'] ?? false,
      progress: json['progress'] ?? 0,
      sentence: json['sentence'] ?? '',
      newWord: json['new_word'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ClassesResponse {
  final int totalClasses;
  final List<String> classes;
  
  ClassesResponse({
    required this.totalClasses,
    required this.classes,
  });
  
  factory ClassesResponse.fromJson(Map<String, dynamic> json) {
    final classes = (json['classes'] as List?)?.cast<String>() ?? [];
    return ClassesResponse(
      totalClasses: json['total_classes'] ?? 0,
      classes: classes,
    );
  }
}
