import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignLanguageService {
  // Android emulator  → 10.0.2.2
  // Physical device   → your computer's LAN IP
  static const String baseUrl = 'http://192.168.1.149:8000';

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
  /// Returns the network URL for the sign video.
  /// Call this with VideoPlayerController.networkUrl().
  Future<String> textToSign(String text) async {
    // Validate the word exists first (lightweight check)
    final uri = Uri.parse('$baseUrl/text_to_sign').replace(
      queryParameters: {'text': text},
    );
    final response = await http.head(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 || response.statusCode == 405) {
      // Return the GET URL directly for VideoPlayerController.networkUrl()
      return uri.toString();
    }
    final detail = 'text_to_sign failed (${response.statusCode})';
    throw Exception(detail);
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
