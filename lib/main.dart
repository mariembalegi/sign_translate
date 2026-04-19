import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/result_screen.dart';
import 'screens/camera_screen.dart';
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
        home: MainShell(onThemeToggle: _toggleTheme),
      ),
    );
  }
}

// ── Main shell with PageView + bottom nav ─────────────────────────
class MainShell extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const MainShell({super.key, required this.onThemeToggle});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071329),
      body: Column(
        children: [
          // ── Top header ──────────────────────────────
          SafeArea(
            bottom: false,
            child: Container(
              color: const Color(0xFF071329),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A8AFB), Color(0xFF2255D3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A8AFB).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SignTranslate',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Tunisian Sign Language',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7A90B2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Pages ───────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: const [
                ResultScreen(),
                CameraScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentPage,
        onTap: _goToPage,
      ),
    );
  }
}

// ── Bottom navigation bar ────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = const Color(0xFF0D1B2E);
    final activeColor = const Color(0xFF3A7BF7);
    final inactiveColor = const Color(0xFF4A6080);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: const Color(0xFF1B2A42), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.translate_rounded,
                label: 'Text to Sign',
                active: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.photo_camera_outlined,
                label: 'Sign to Text',
                active: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: active ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
