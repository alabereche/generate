import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logger.dart';
import 'app_manager.dart';
import 'error_handler.dart';
import 'analytics.dart';

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  bool _isInitialized = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  /// تهيئة التطبيق
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('App already initialized', 'AppInitializer');
      return;
    }

    Logger.startup('app_initializer_started');
    final stopwatch = Stopwatch()..start();

    try {
      // تعيين إعدادات النظام
      await _setupSystemSettings();
      Logger.startup('system_settings_configured');

      // تهيئة مدير التطبيق
      await AppManager().initialize();
      Logger.startup('app_manager_initialized');

      // تهيئة معالج الأخطاء
      ErrorHandler().initialize();
      Logger.startup('error_handler_initialized');

      // تهيئة التحليلات
      Analytics().setEnabled(true);
      Logger.startup('analytics_initialized');

      _isInitialized = true;
      _initializationCompleter.complete();
      stopwatch.stop();

      Logger.startup('app_initializer_completed', stopwatch.elapsed);

    } catch (e, stackTrace) {
      stopwatch.stop();
      Logger.error('App initialization failed', 'AppInitializer', e, stackTrace);
      
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.completeError(e);
      }
      
      rethrow;
    }
  }

  /// إعداد إعدادات النظام
  Future<void> _setupSystemSettings() async {
    try {
      // تعيين اتجاه التطبيق للغة العربية
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // تعيين شريط الحالة
      await SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // تعيين نمط التنقل
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      Logger.info('System settings configured', 'AppInitializer');
    } catch (e) {
      Logger.error('Failed to configure system settings', 'AppInitializer', e);
      rethrow;
    }
  }

  /// انتظار تهيئة التطبيق
  Future<void> waitForInitialization() async {
    if (_isInitialized) return;
    await _initializationCompleter.future;
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// الحصول على حالة التهيئة
  Future<InitializationStatus> getInitializationStatus() async {
    try {
      final appStatus = await AppManager().getAppStatus();
      final healthCheck = await AppManager().healthCheck();

      return InitializationStatus(
        isInitialized: _isInitialized,
        appStatus: appStatus,
        healthCheck: healthCheck,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      Logger.error('Failed to get initialization status', 'AppInitializer', e);
      return InitializationStatus(
        isInitialized: _isInitialized,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// إعادة تهيئة التطبيق
  Future<void> reinitialize() async {
    try {
      Logger.info('App reinitialization started', 'AppInitializer');

      // إغلاق التطبيق الحالي
      await AppManager().dispose();

      // إعادة تعيين الحالة
      _isInitialized = false;

      // إعادة التهيئة
      await initialize();

      Logger.info('App reinitialization completed', 'AppInitializer');
    } catch (e) {
      Logger.error('App reinitialization failed', 'AppInitializer', e);
      rethrow;
    }
  }

  /// تنظيف التطبيق
  Future<void> cleanup() async {
    try {
      Logger.shutdown('app_cleanup_started');

      await AppManager().cleanup();

      Logger.shutdown('app_cleanup_completed');
    } catch (e) {
      Logger.error('App cleanup failed', 'AppInitializer', e);
    }
  }

  /// إغلاق مُهيئ التطبيق
  Future<void> dispose() async {
    try {
      Logger.shutdown('app_initializer_disposal_started');

      await cleanup();
      await AppManager().dispose();

      Logger.shutdown('app_initializer_disposal_completed');
    } catch (e) {
      Logger.error('App initializer disposal failed', 'AppInitializer', e);
    }
  }
}

/// حالة التهيئة
class InitializationStatus {
  final bool isInitialized;
  final Map<String, dynamic>? appStatus;
  final Map<String, dynamic>? healthCheck;
  final String? error;
  final DateTime timestamp;

  InitializationStatus({
    required this.isInitialized,
    this.appStatus,
    this.healthCheck,
    this.error,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_initialized': isInitialized,
      'app_status': appStatus,
      'health_check': healthCheck,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'InitializationStatus(isInitialized: $isInitialized, error: $error, timestamp: $timestamp)';
  }
}

/// Widget لتهيئة التطبيق
class AppInitializerWidget extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onInitialized;
  final Function(String)? onError;

  const AppInitializerWidget({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.onInitialized,
    this.onError,
  });

  @override
  State<AppInitializerWidget> createState() => _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends State<AppInitializerWidget> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await AppInitializer().initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        widget.onInitialized?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        
        widget.onError?.call(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget ?? _buildDefaultErrorWidget();
    }

    if (!_isInitialized) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultLoadingWidget() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل التطبيق...'),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'خطأ في تحميل التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'حدث خطأ غير متوقع',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}