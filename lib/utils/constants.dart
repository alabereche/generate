class AppConstants {
  // API Configuration
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String geminiModel = 'google/gemini-2.5-flash-image-preview:free';
  static const String apiKey = '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';
  
  // App Configuration
  static const String appName = 'AI Vision Chat';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق الذكاء الاصطناعي المتكامل';
  
  // Storage Keys
  static const String settingsBox = 'settings';
  static const String chatBox = 'chat_messages';
  static const String isDarkModeKey = 'isDarkMode';
  static const String languageKey = 'language';
  static const String autoSaveImagesKey = 'autoSaveImages';
  
  // Image Configuration
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  
  // Chat Configuration
  static const int maxChatMessages = 100;
  static const int maxMessageLength = 1000;
  static const int typingDelay = 1000; // milliseconds
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // Error Messages
  static const String networkError = 'خطأ في الاتصال بالإنترنت';
  static const String apiError = 'خطأ في الخدمة، يرجى المحاولة مرة أخرى';
  static const String permissionError = 'يجب منح الأذونات المطلوبة';
  static const String imageError = 'خطأ في معالجة الصورة';
  static const String saveError = 'خطأ في حفظ الملف';
  
  // Success Messages
  static const String imageSaved = 'تم حفظ الصورة بنجاح';
  static const String imageShared = 'تم مشاركة الصورة بنجاح';
  static const String analysisComplete = 'تم تحليل الصورة بنجاح';
  static const String generationComplete = 'تم توليد الصورة بنجاح';
  
  // Placeholder Texts
  static const String imageAnalysisPlaceholder = 'اختر صورة لتحليل محتواها';
  static const String imageGenerationPlaceholder = 'اكتب وصفاً للصورة المطلوبة';
  static const String chatPlaceholder = 'اكتب رسالتك هنا...';
  
  // Tips for Image Generation
  static const List<String> imageGenerationTips = [
    'كن محدداً في الوصف',
    'أضف تفاصيل الألوان',
    'حدد النمط الفني',
    'اذكر الإضاءة',
    'صف المشاعر المطلوبة',
    'حدد زاوية التصوير',
  ];
  
  // Example Questions for Chat
  static const List<String> exampleQuestions = [
    'ما هو الطقس اليوم؟',
    'كيف أتعلم البرمجة؟',
    'أخبرني قصة قصيرة',
    'ما هو أفضل مطعم في المدينة؟',
    'كيف أحافظ على صحتي؟',
    'ما هي أفضل الطرق للتعلم؟',
  ];
  
  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'ar': 'العربية',
    'en': 'English',
  };
  
  // Default Language
  static const String defaultLanguage = 'ar';
  
  // File Extensions
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.bmp',
    '.gif',
  ];
  
  // Cache Configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiration = Duration(days: 7);
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double defaultElevation = 4.0;
  static const double defaultIconSize = 24.0;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Performance Configuration
  static const int maxConcurrentRequests = 3;
  static const Duration requestDelay = Duration(milliseconds: 500);
  
  // Security Configuration
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
}