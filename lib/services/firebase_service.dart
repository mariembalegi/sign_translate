import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }
  
  FirebaseService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth {
    if (!_isFirebaseReady) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    if (!_isFirebaseReady) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }
  
  // ============ INITIALIZATION ============
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }


    // ============ AUTH METHODS ============
    User? getCurrentUser() {
      try {
        return FirebaseAuth.instance.currentUser;
      } catch (_) {
        return null;
      }
    }

    Stream<User?> authStateChanges() {
      try {
        return FirebaseAuth.instance.authStateChanges();
      } catch (_) {
        return Stream.value(null);
      }
  }
  
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not configured yet.');
    }

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not configured yet.');
    }

    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  Future<UserCredential> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not configured yet.');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Sign in aborted by user');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await auth.signInWithCredential(credential);
      
      // Create user document if new user
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }
  
  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;

    try {
      await _googleSignIn.signOut();
      await auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  
  Future<void> resetPassword(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not configured yet.');
    }

    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // ============ FIRESTORE METHODS ============
  
  // Translation History
  Future<void> addTranslationRecord(String gesture, double confidence, {String? notes}) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) return;

    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('translations')
          .add({
        'gesture': gesture,
        'confidence': confidence,
        'notes': notes ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save translation: $e');
    }
  }
  
  Future<List<TranslationData>> getTranslationHistory({int limit = 50}) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return [];
    }

    final user = auth.currentUser;
    if (user == null) return [];
    
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('translations')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => TranslationData.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch translation history: $e');
    }
  }
  
  Stream<List<TranslationData>> getTranslationHistoryStream({int limit = 50}) {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return Stream.value([]);
    }

    final user = auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TranslationData.fromFirestore(doc)).toList());
  }
  
  // Favorites
  Future<void> addFavorite(String gesture) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) return;

    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(gesture)
          .set({
        'gesture': gesture,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }
  
  Future<void> removeFavorite(String gesture) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) return;

    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(gesture)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
  
  Future<List<String>> getFavorites() async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return [];
    }

    final user = auth.currentUser;
    if (user == null) return [];
    
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      
      return snapshot.docs.map((doc) => doc['gesture'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }
  
  Stream<List<String>> getFavoritesStream() {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return Stream.value([]);
    }

    final user = auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['gesture'] as String).toList());
  }
  
  // User Statistics
  Future<UserStats> getUserStats() async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return UserStats.empty();
    }

    final user = auth.currentUser;
    if (user == null) return UserStats.empty();
    
    try {
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('overview')
          .get();
      
      if (doc.exists) {
        return UserStats.fromFirestore(doc);
      }
      return UserStats.empty();
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }
  
  Future<void> updateUserStats(String gesture, double confidence) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) return;

    final user = auth.currentUser;
    if (user == null) return;
    
    try {
      final statsRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('overview');
      
      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(statsRef);
        
        int totalTranslations = doc.exists ? doc['totalTranslations'] as int : 0;
        double avgConfidence = doc.exists ? doc['avgConfidence'] as double : 0.0;
        
        totalTranslations++;
        avgConfidence = (avgConfidence * (totalTranslations - 1) + confidence) / totalTranslations;
        
        transaction.set(statsRef, {
          'totalTranslations': totalTranslations,
          'avgConfidence': avgConfidence,
          'lastTranslation': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating stats: $e');
    }
  }
  
  // ============ PRIVATE METHODS ============
  
  Future<void> _createUserDocument(User user) async {
    final firestore = _firestore;
    if (firestore == null) return;

    try {
      final userDoc = firestore.collection('users').doc(user.uid);
      final exists = (await userDoc.get()).exists;
      
      if (!exists) {
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName ?? 'User',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
  
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

// ============ DATA MODELS ============

class TranslationData {
  final String id;
  final String gesture;
  final double confidence;
  final String notes;
  final DateTime timestamp;
  
  TranslationData({
    required this.id,
    required this.gesture,
    required this.confidence,
    required this.notes,
    required this.timestamp,
  });
  
  factory TranslationData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TranslationData(
      id: doc.id,
      gesture: data['gesture'] ?? '',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'gesture': gesture,
      'confidence': confidence,
      'notes': notes,
      'timestamp': timestamp,
    };
  }
}

class UserStats {
  final int totalTranslations;
  final double avgConfidence;
  final DateTime? lastTranslation;
  
  UserStats({
    required this.totalTranslations,
    required this.avgConfidence,
    this.lastTranslation,
  });
  
  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      totalTranslations: data['totalTranslations'] as int? ?? 0,
      avgConfidence: (data['avgConfidence'] as num?)?.toDouble() ?? 0.0,
      lastTranslation: (data['lastTranslation'] as Timestamp?)?.toDate(),
    );
  }
  
  factory UserStats.empty() {
    return UserStats(
      totalTranslations: 0,
      avgConfidence: 0.0,
    );
  }
}
