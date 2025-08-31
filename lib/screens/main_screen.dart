import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/image_analysis_screen.dart';
import '../screens/image_generation_screen.dart';
import '../screens/chat_screen.dart';
import '../providers/app_providers.dart';
import '../constants/app_colors.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ImageAnalysisScreen(),
    const ImageGenerationScreen(),
    const ChatScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(LucideIcons.search),
      activeIcon: Icon(LucideIcons.search),
      label: 'تحليل الصور',
    ),
    const BottomNavigationBarItem(
      icon: Icon(LucideIcons.wand2),
      activeIcon: Icon(LucideIcons.wand2),
      label: 'توليد الصور',
    ),
    const BottomNavigationBarItem(
      icon: Icon(LucideIcons.messageCircle),
      activeIcon: Icon(LucideIcons.messageCircle),
      label: 'الدردشة',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: isDark 
              ? AppColors.glassGradientDark 
              : AppColors.glassGradient,
          border: Border(
            top: BorderSide(
              color: isDark 
                  ? AppColors.borderDark.withOpacity(0.3)
                  : AppColors.borderLight.withOpacity(0.3),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? AppColors.shadowDark 
                  : AppColors.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: isDark 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondaryLight,
              selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.labelSmall,
              items: _navigationItems,
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    final settings = ref.watch(appSettingsProvider);
    final isDark = settings.isDarkMode;

    // إظهار FAB فقط في شاشة الدردشة
    if (_currentIndex != 2) return null;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // يمكن إضافة وظيفة إضافية هنا
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          LucideIcons.plus,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);
    final isDark = settings.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark 
            ? AppColors.glassGradientDark 
            : AppColors.glassGradient,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.borderDark.withOpacity(0.3)
                : AppColors.borderLight.withOpacity(0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.shadowDark 
                : AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: showBackButton
                ? IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.arrowRight,
                      color: isDark 
                          ? AppColors.textPrimaryDark 
                          : AppColors.textPrimaryLight,
                    ),
                  )
                : null,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}