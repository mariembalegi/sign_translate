import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late TranslationProvider _translationProvider;
  
  @override
  void initState() {
    super.initState();
    _translationProvider = context.read<TranslationProvider>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        elevation: 0,
      ),
      body: StreamBuilder<List<TranslationData>>(
        stream: _translationProvider.getHistoryStream(),
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
          
          final translations = snapshot.data ?? [];
          
          if (translations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No translations yet',
                    style: AppText.heading3.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Start translating to see your history',
                    style: AppText.bodySmall,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: translations.length,
            itemBuilder: (context, index) {
              final translation = translations[index];
              return _buildTranslationCard(context, translation);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildTranslationCard(
    BuildContext context,
    TranslationData translation,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        // Show details
        _showTranslationDetails(context, translation);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translation.gesture,
                    style: AppText.heading3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(translation.timestamp),
                    style: AppText.bodySmall,
                  ),
                ],
              ),
              Consumer<TranslationProvider>(
                builder: (_, provider, __) => IconButton(
                  icon: Icon(
                    provider.isFavorite(translation.gesture)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: provider.isFavorite(translation.gesture)
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () =>
                      provider.toggleFavorite(translation.gesture),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ConfidenceBar(confidence: translation.confidence),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence',
                style: AppText.bodySmall,
              ),
              Text(
                '${(translation.confidence * 100).toStringAsFixed(1)}%',
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getConfidenceColor(translation.confidence),
                ),
              ),
            ],
          ),
          if (translation.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Notes: ${translation.notes}',
              style: AppText.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
  
  void _showTranslationDetails(
    BuildContext context,
    TranslationData translation,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusLg),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translation.gesture,
              style: AppText.heading2,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow('Detected Gesture:', translation.gesture),
            _buildDetailRow(
              'Confidence:',
              '${(translation.confidence * 100).toStringAsFixed(2)}%',
            ),
            _buildDetailRow(
              'Timestamp:',
              DateFormat('MMM dd, yyyy - HH:mm:ss').format(translation.timestamp),
            ),
            if (translation.notes.isNotEmpty)
              _buildDetailRow('Notes:', translation.notes),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Copy Gesture',
                    onPressed: () {
                      // Copy to clipboard
                      Navigator.pop(context);
                    },
                    icon: Icons.content_copy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppText.body,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
