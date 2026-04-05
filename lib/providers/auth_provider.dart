import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthProvider() {
    _firebaseService.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firebaseService.signUpWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firebaseService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firebaseService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firebaseService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class TranslationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<TranslationData> _history = [];
  List<String> _favorites = [];
  UserStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  
  TranslationProvider() {
    _loadData();
  }
  
  List<TranslationData> get history => _history;
  List<String> get favorites => _favorites;
  UserStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> _loadData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _history = await _firebaseService.getTranslationHistory();
      _favorites = await _firebaseService.getFavorites();
      _stats = await _firebaseService.getUserStats();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addTranslation(String gesture, double confidence, {String? notes}) async {
    try {
      await _firebaseService.addTranslationRecord(gesture, confidence, notes: notes);
      await _firebaseService.updateUserStats(gesture, confidence);
      await _loadData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> toggleFavorite(String gesture) async {
    try {
      if (_favorites.contains(gesture)) {
        await _firebaseService.removeFavorite(gesture);
        _favorites.remove(gesture);
      } else {
        await _firebaseService.addFavorite(gesture);
        _favorites.add(gesture);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  bool isFavorite(String gesture) {
    return _favorites.contains(gesture);
  }
  
  Stream<List<TranslationData>> getHistoryStream() {
    return _firebaseService.getTranslationHistoryStream();
  }
  
  Stream<List<String>> getFavoritesStream() {
    return _firebaseService.getFavoritesStream();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
