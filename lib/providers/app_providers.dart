import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../services/openrouter_service.dart';

// مزود خدمة OpenRouter
final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService();
});

// مزود إعدادات التطبيق
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

// مزود حالة تحليل الصور
final imageAnalysisProvider = StateNotifierProvider<ImageAnalysisNotifier, ImageAnalysisState>((ref) {
  return ImageAnalysisNotifier(ref.read(openRouterServiceProvider));
});

// مزود حالة توليد الصور
final imageGenerationProvider = StateNotifierProvider<ImageGenerationNotifier, ImageGenerationState>((ref) {
  return ImageGenerationNotifier(ref.read(openRouterServiceProvider));
});

// مزود حالة الدردشة
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(openRouterServiceProvider));
});

// مزود Hive Box للرسائل
final chatBoxProvider = FutureProvider<Box<ChatMessage>>((ref) async {
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  return await Hive.openBox<ChatMessage>('chat_messages');
});

// إعدادات التطبيق
class AppSettings {
  final bool isDarkMode;
  final String language;
  final bool autoSaveImages;

  AppSettings({
    this.isDarkMode = false,
    this.language = 'ar',
    this.autoSaveImages = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? language,
    bool? autoSaveImages,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      autoSaveImages: autoSaveImages ?? this.autoSaveImages,
    );
  }
}

// مزود إعدادات التطبيق
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      language: prefs.getString('language') ?? 'ar',
      autoSaveImages: prefs.getBool('autoSaveImages') ?? true,
    );
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !state.isDarkMode);
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    state = state.copyWith(language: language);
  }

  Future<void> setAutoSaveImages(bool autoSave) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSaveImages', autoSave);
    state = state.copyWith(autoSaveImages: autoSave);
  }
}

// حالة تحليل الصور
class ImageAnalysisState {
  final bool isLoading;
  final String? result;
  final String? error;
  final String? selectedImagePath;

  ImageAnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
    this.selectedImagePath,
  });

  ImageAnalysisState copyWith({
    bool? isLoading,
    String? result,
    String? error,
    String? selectedImagePath,
  }) {
    return ImageAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
    );
  }
}

// مزود تحليل الصور
class ImageAnalysisNotifier extends StateNotifier<ImageAnalysisState> {
  final OpenRouterService _openRouterService;

  ImageAnalysisNotifier(this._openRouterService) : super(ImageAnalysisState());

  void setSelectedImage(String imagePath) {
    state = state.copyWith(
      selectedImagePath: imagePath,
      result: null,
      error: null,
    );
  }

  Future<void> analyzeImage() async {
    if (state.selectedImagePath == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final file = File(state.selectedImagePath!);
      final result = await _openRouterService.analyzeImage(file);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = state.copyWith(result: null, error: null);
  }
}

// حالة توليد الصور
class ImageGenerationState {
  final bool isLoading;
  final String? generatedImageUrl;
  final String? error;
  final String prompt;

  ImageGenerationState({
    this.isLoading = false,
    this.generatedImageUrl,
    this.error,
    this.prompt = '',
  });

  ImageGenerationState copyWith({
    bool? isLoading,
    String? generatedImageUrl,
    String? error,
    String? prompt,
  }) {
    return ImageGenerationState(
      isLoading: isLoading ?? this.isLoading,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      error: error ?? this.error,
      prompt: prompt ?? this.prompt,
    );
  }
}

// مزود توليد الصور
class ImageGenerationNotifier extends StateNotifier<ImageGenerationState> {
  final OpenRouterService _openRouterService;

  ImageGenerationNotifier(this._openRouterService) : super(ImageGenerationState());

  void setPrompt(String prompt) {
    state = state.copyWith(prompt: prompt);
  }

  Future<void> generateImage() async {
    if (state.prompt.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final imageUrl = await _openRouterService.generateImage(state.prompt);
      state = state.copyWith(isLoading: false, generatedImageUrl: imageUrl);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveImage() async {
    if (state.generatedImageUrl == null) return;

    try {
      await _openRouterService.saveImageFromUrl(state.generatedImageUrl!);
    } catch (e) {
      state = state.copyWith(error: 'خطأ في حفظ الصورة: $e');
    }
  }

  void clearGeneratedImage() {
    state = state.copyWith(generatedImageUrl: null, error: null);
  }
}

// حالة الدردشة
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// مزود الدردشة
class ChatNotifier extends StateNotifier<ChatState> {
  final OpenRouterService _openRouterService;

  ChatNotifier(this._openRouterService) : super(ChatState());

  void addMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    addMessage(userMessage);

    state = state.copyWith(isLoading: true, error: null);

    try {
      // إرسال الرسالة إلى AI
      final response = await _openRouterService.chatWithAI(content);
      
      // إضافة رد AI
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      addMessage(aiMessage);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearChat() {
    state = state.copyWith(messages: []);
  }

  void loadMessages(List<ChatMessage> messages) {
    state = state.copyWith(messages: messages);
  }
}