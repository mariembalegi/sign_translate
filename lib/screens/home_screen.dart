import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TranslationProvider _translationProvider;

  @override
  void initState() {
    super.initState();
    _translationProvider = context.read<TranslationProvider>();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // ── Header ──────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
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
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SignTranslate',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: Color(0xFF0F1D35),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Tunisian Sign Language AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A90B2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Stats row (was hero card) ─────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.record_voice_over_outlined,
                        value: '24',
                        label: 'Signs',
                        color: const Color(0xFF4A8AFB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.bolt_rounded,
                        value: 'AI',
                        label: 'Powered',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.language_outlined,
                        value: 'TSL',
                        label: 'Language',
                        color: const Color(0xFF34C38F),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Section title ────────────────────────────
                const Text(
                  'Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F1D35),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Primary tool card — Sign to Text ─────────
                _PrimaryToolCard(
                  icon: Icons.photo_camera_outlined,
                  iconColor: const Color(0xFF4A8AFB),
                  iconBg: const Color(0xFFEBF2FF),
                  title: 'Sign to Text',
                  description: 'Point your camera at hand signs and get live text translation powered by AI.',
                  tag: 'LIVE',
                  tagColor: const Color(0xFF4A8AFB),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CameraScreen())),
                ),

                const SizedBox(height: 14),

                // ── Secondary tool card — Text to Sign ────────
                _PrimaryToolCard(
                  icon: Icons.sign_language_outlined,
                  iconColor: const Color(0xFF34C38F),
                  iconBg: const Color(0xFFE6F9F2),
                  title: 'Text to Sign',
                  description: 'Type any word and watch an avatar demonstrate the corresponding sign.',
                  tag: 'AVATAR',
                  tagColor: const Color(0xFF34C38F),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ResultScreen())),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Primary Tool Card ────────────────────────────────────────────
class _PrimaryToolCard extends StatelessWidget {
  const _PrimaryToolCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String tag;
  final Color tagColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEAEFF8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0F172A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F1D35),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF7A90B2),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 15, color: const Color(0xFFB0C0D8)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEFF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9AACC4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
