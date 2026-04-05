import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class SignLanguageService {
  static const String baseUrl = 'http://localhost:8000'; // Change for production
  
  static final SignLanguageService _instance = SignLanguageService._internal();
  
  factory SignLanguageService() {
    return _instance;
  }
  
  SignLanguageService._internal();
  
  Future<HealthCheckResponse> getHealthStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HealthCheckResponse.fromJson(data);
      }
      throw Exception('Failed to get health status');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  Future<PredictionResponse> predictFromImage(Uint8List imageBytes) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict/image'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'gesture.jpg',
        ),
      );
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PredictionResponse.fromJson(data);
      }
      throw Exception('Prediction failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Prediction error: $e');
    }
  }
  
  Future<ClassesResponse> getAvailableClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/models/classes'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClassesResponse.fromJson(data);
      }
      throw Exception('Failed to get classes');
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
  final String timestamp;
  final Map<String, double>? allPredictions;
  
  PredictionResponse({
    required this.gesture,
    required this.confidence,
    required this.timestamp,
    this.allPredictions,
  });
  
  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      gesture: json['gesture'] ?? 'Unknown',
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      allPredictions: json['all_predictions'] != null
          ? Map.from(json['all_predictions']).cast<String, double>()
          : null,
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
