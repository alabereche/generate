import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

class ImageAnalysisScreen extends ConsumerStatefulWidget {
  const ImageAnalysisScreen({super.key});

  @override
  ConsumerState<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends ConsumerState<ImageAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(imageAnalysisProvider.notifier).setSelectedImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(imageAnalysisProvider.notifier).setSelectedImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في التقاط الصورة: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(imageAnalysisProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Text(
                'تحليل الصور',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر صورة لتحليل محتواها باستخدام الذكاء الاصطناعي',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // أزرار اختيار الصورة
              if (analysisState.selectedImagePath == null) ...[
                GlassCard(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 64,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'اختر صورة للتحليل',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يمكنك اختيار صورة من المعرض أو التقاط صورة جديدة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark 
                              ? AppColors.textSecondaryDark 
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              text: 'من المعرض',
                              icon: LucideIcons.image,
                              onPressed: _pickImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassButton(
                              text: 'التقاط صورة',
                              icon: LucideIcons.camera,
                              onPressed: _takePhoto,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // عرض الصورة المختارة
              if (analysisState.selectedImagePath != null) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'الصورة المختارة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(imageAnalysisProvider.notifier).clearResult();
                            },
                            icon: const Icon(LucideIcons.x),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.accentRed.withOpacity(0.1),
                              foregroundColor: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(analysisState.selectedImagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(
                        text: analysisState.isLoading ? 'جاري التحليل...' : 'تحليل الصورة',
                        icon: analysisState.isLoading ? null : LucideIcons.search,
                        isLoading: analysisState.isLoading,
                        onPressed: analysisState.isLoading 
                            ? null 
                            : () => ref.read(imageAnalysisProvider.notifier).analyzeImage(),
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ],

              // عرض نتيجة التحليل
              if (analysisState.result != null) ...[
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.brain,
                            color: AppColors.accentGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'نتيجة التحليل',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppColors.surfaceDark.withOpacity(0.5)
                              : AppColors.surfaceLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark 
                                ? AppColors.borderDark.withOpacity(0.3)
                                : AppColors.borderLight.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          analysisState.result!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // عرض الأخطاء
              if (analysisState.error != null) ...[
                const SizedBox(height: 16),
                GlassCard(
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        color: AppColors.accentRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          analysisState.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}