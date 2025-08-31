import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_input_field.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

class ImageGenerationScreen extends ConsumerStatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  ConsumerState<ImageGenerationScreen> createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends ConsumerState<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    try {
      final state = ref.read(imageGenerationProvider);
      if (state.generatedImageUrl == null) return;

      final result = await ImageGallerySaver.saveImage(
        state.generatedImageUrl!,
        quality: 100,
        name: 'generated_image_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        _showSuccessSnackBar('تم حفظ الصورة بنجاح');
      } else {
        _showErrorSnackBar('فشل في حفظ الصورة');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ الصورة: $e');
    }
  }

  Future<void> _shareImage() async {
    try {
      final state = ref.read(imageGenerationProvider);
      if (state.generatedImageUrl == null) return;

      await Share.share(
        'شاهد هذه الصورة المولدة بالذكاء الاصطناعي!',
        subject: 'صورة مولدة بالذكاء الاصطناعي',
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في مشاركة الصورة: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
    final generationState = ref.watch(imageGenerationProvider);
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
                'توليد الصور',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اكتب وصفاً للصورة التي تريد توليدها باستخدام الذكاء الاصطناعي',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // حقل إدخال الوصف
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وصف الصورة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassInputField(
                      controller: _promptController,
                      hintText: 'مثال: منظر طبيعي جميل مع جبال خضراء وبحيرة زرقاء في وقت الغروب',
                      maxLines: 3,
                      onChanged: (value) {
                        ref.read(imageGenerationProvider.notifier).setPrompt(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    GlassButton(
                      text: generationState.isLoading ? 'جاري التوليد...' : 'توليد الصورة',
                      icon: generationState.isLoading ? null : LucideIcons.wand2,
                      isLoading: generationState.isLoading,
                      onPressed: generationState.isLoading || generationState.prompt.trim().isEmpty
                          ? null
                          : () => ref.read(imageGenerationProvider.notifier).generateImage(),
                      width: double.infinity,
                    ),
                  ],
                ),
              ),

              // عرض الصورة المولدة
              if (generationState.generatedImageUrl != null) ...[
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.image,
                            color: AppColors.accentGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الصورة المولدة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              ref.read(imageGenerationProvider.notifier).clearGeneratedImage();
                            },
                            icon: const Icon(LucideIcons.x),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.accentRed.withOpacity(0.1),
                              foregroundColor: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          generationState.generatedImageUrl!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? AppColors.surfaceDark.withOpacity(0.5)
                                    : AppColors.surfaceLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? AppColors.surfaceDark.withOpacity(0.5)
                                    : AppColors.surfaceLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.alertCircle,
                                    color: AppColors.accentRed,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'خطأ في تحميل الصورة',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accentRed,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              text: 'حفظ الصورة',
                              icon: LucideIcons.download,
                              onPressed: _saveImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassButton(
                              text: 'مشاركة',
                              icon: LucideIcons.share2,
                              onPressed: _shareImage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // عرض الأخطاء
              if (generationState.error != null) ...[
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
                          generationState.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // نصائح
              if (generationState.generatedImageUrl == null && !generationState.isLoading) ...[
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.lightbulb,
                            color: AppColors.accentYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'نصائح للحصول على نتائج أفضل',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('كن محدداً في الوصف', 'مثال: "قطة سوداء تجلس على كرسي أحمر" بدلاً من "قطة"'),
                      _buildTip('أضف تفاصيل الألوان', 'اذكر الألوان الرئيسية في الصورة'),
                      _buildTip('حدد النمط الفني', 'مثال: "رسم رقمي" أو "صورة فوتوغرافية"'),
                      _buildTip('اذكر الإضاءة', 'مثال: "في وقت الغروب" أو "إضاءة ناعمة"'),
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

  Widget _buildTip(String title, String description) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}