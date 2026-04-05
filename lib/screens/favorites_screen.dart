import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Gestures'),
        elevation: 0,
      ),
      body: Consumer<TranslationProvider>(
        builder: (context, provider, _) {
          return StreamBuilder<List<String>>(
            stream: provider.getFavoritesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: AppSpacing.md),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }
              
              final favorites = snapshot.data ?? [];
              
              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No favorites yet',
                        style: AppText.heading3.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Add gestures to your favorites for quick access',
                        style: AppText.bodySmall,
                      ),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.2,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final gesture = favorites[index];
                  return _buildGestureCard(context, gesture, provider);
                },
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildGestureCard(
    BuildContext context,
    String gesture,
    TranslationProvider provider,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {
        // Show gesture details or play animation
      },
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  gesture,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Remove button
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: GestureDetector(
              onTap: () {
                provider.toggleFavorite(gesture);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$gesture removed from favorites'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
