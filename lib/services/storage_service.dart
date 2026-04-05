import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;
  
  factory StorageService() {
    return _instance;
  }
  
  StorageService._internal();
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // History management
  Future<void> addToTranslationHistory(TranslationRecord record) async {
    final history = await getTranslationHistory();
    history.insert(0, record);
    
    // Keep only last 100 records
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    final jsonList = history.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList('translation_history', jsonList);
  }
  
  Future<List<TranslationRecord>> getTranslationHistory() async {
    final jsonList = _prefs.getStringList('translation_history') ?? [];
    return jsonList.map((json) {
      final data = jsonDecode(json);
      return TranslationRecord.fromJson(data);
    }).toList();
  }
  
  Future<void> clearTranslationHistory() async {
    await _prefs.remove('translation_history');
  }
  
  // Settings
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool('dark_mode', isDark);
  }
  
  bool getDarkMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }
  
  Future<void> setServerUrl(String url) async {
    await _prefs.setString('server_url', url);
  }
  
  String getServerUrl() {
    return _prefs.getString('server_url') ?? 'http://localhost:8000';
  }
  
  Future<void> setConfidenceThreshold(double threshold) async {
    await _prefs.setDouble('confidence_threshold', threshold);
  }
  
  double getConfidenceThreshold() {
    return _prefs.getDouble('confidence_threshold') ?? 0.7;
  }
  
  // Favorites
  Future<void> addFavorite(String gesture) async {
    final favorites = getFavorites();
    if (!favorites.contains(gesture)) {
      favorites.add(gesture);
      await _prefs.setStringList('favorites', favorites);
    }
  }
  
  List<String> getFavorites() {
    return _prefs.getStringList('favorites') ?? [];
  }
  
  Future<void> removeFavorite(String gesture) async {
    final favorites = getFavorites();
    favorites.remove(gesture);
    await _prefs.setStringList('favorites', favorites);
  }
}

class TranslationRecord {
  final String gesture;
  final double confidence;
  final DateTime timestamp;
  final String? notes;
  
  TranslationRecord({
    required this.gesture,
    required this.confidence,
    required this.timestamp,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'gesture': gesture,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
  
  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      gesture: json['gesture'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }
}
