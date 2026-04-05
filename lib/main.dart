import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final storage = StorageService();
  await storage.init();
  
  // Initialize Firebase (with error handling)
  try {
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization warning: $e');
    print('The app will run in demo mode. Configure Firebase to enable cloud features.');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StorageService _storage;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _storage = StorageService();
    _isDarkMode = _storage.getDarkMode();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _storage.setDarkMode(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ],
      child: MaterialApp(
        title: 'Sign Language Translator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(onThemeToggle: _toggleTheme),
      ),
    );
  }
}