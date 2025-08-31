import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';
import 'analytics.dart';
import 'cache_manager.dart';
import 'network_manager.dart';
import 'performance_monitor.dart';
import 'error_handler.dart';
import 'app_lifecycle_manager.dart';

class AppManager {
  static final AppManager _instance = AppManager._internal();
  factory AppManager() => _instance;
  AppManager._internal();

  bool _isInitialized = false;
  final List<Completer<void>> _initializationCompleters = [];

  /// تهيئة مدير التطبيق
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.info('App manager already initialized', 'AppManager');
      return;
    }

    Logger.startup('app_initialization_started');
    final stopwatch = Stopwatch()..start();

    try {
      // تهيئة معالج الأخطاء أولاً
      ErrorHandler().initialize();
      Logger.startup('error_handler_initialized');

      // تهيئة مدير الشبكة
      await NetworkManager().initialize();
      Logger.startup('network_manager_initialized');

      // تهيئة مدير التخزين المؤقت
      await CacheManager().initialize();
      Logger.startup('cache_manager_initialized');

      // تهيئة مراقب الأداء
      PerformanceMonitor().startMonitoring();
      Logger.startup('performance_monitor_initialized');

      // تهيئة التحليلات
      Analytics().setEnabled(kDebugMode);
      Logger.startup('analytics_initialized');

      // تهيئة مدير دورة الحياة
      AppLifecycleManager().initialize();
      Logger.startup('lifecycle_manager_initialized');

      _isInitialized = true;
      stopwatch.stop();

      Logger.startup('app_initialization_completed', stopwatch.elapsed);

      // إكمال جميع المكملات المعلقة
      for (final completer in _initializationCompleters) {
        completer.complete();
      }
      _initializationCompleters.clear();

      // تسجيل حدث فتح التطبيق
      Analytics().logAppOpen();

    } catch (e, stackTrace) {
      stopwatch.stop();
      Logger.error('App initialization failed', 'AppManager', e, stackTrace);
      
      // إكمال جميع المكملات المعلقة مع خطأ
      for (final completer in _initializationCompleters) {
        completer.completeError(e);
      }
      _initializationCompleters.clear();
      
      rethrow;
    }
  }

  /// انتظار تهيئة التطبيق
  Future<void> waitForInitialization() async {
    if (_isInitialized) return;

    final completer = Completer<void>();
    _initializationCompleters.add(completer);
    await completer.future;
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// الحصول على تقرير حالة التطبيق
  Future<Map<String, dynamic>> getAppStatus() async {
    try {
      final networkInfo = await NetworkManager().getNetworkInfo();
      final cacheInfo = await CacheManager().getCacheInfo();
      final performanceStats = PerformanceMonitor().getPerformanceStats();
      final errorStats = ErrorHandler().getErrorStats();
      final sessionInfo = AppLifecycleManager().getSessionInfo();

      return {
        'timestamp': DateTime.now().toIso8601String(),
        'is_initialized': _isInitialized,
        'network': networkInfo,
        'cache': cacheInfo,
        'performance': performanceStats,
        'errors': errorStats,
        'session': sessionInfo,
      };
    } catch (e) {
      Logger.error('Failed to get app status', 'AppManager', e);
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'is_initialized': _isInitialized,
        'error': e.toString(),
      };
    }
  }

  /// الحصول على تقرير شامل عن التطبيق
  Future<Map<String, dynamic>> getComprehensiveReport() async {
    try {
      final stopwatch = Stopwatch()..start();

      final networkReport = await NetworkManager().getComprehensiveReport();
      final cacheInfo = await CacheManager().getCacheInfo();
      final performanceReport = await PerformanceMonitor().getComprehensiveReport();
      final errorReport = ErrorHandler().getComprehensiveReport();
      final lifecycleReport = AppLifecycleManager().getComprehensiveReport();

      stopwatch.stop();

      return {
        'report_timestamp': DateTime.now().toIso8601String(),
        'report_generation_time_ms': stopwatch.elapsedMilliseconds,
        'app_status': {
          'is_initialized': _isInitialized,
          'version': '1.0.0',
          'build_number': '1',
        },
        'network': networkReport,
        'cache': cacheInfo,
        'performance': performanceReport,
        'errors': errorReport,
        'lifecycle': lifecycleReport,
      };
    } catch (e) {
      Logger.error('Failed to get comprehensive report', 'AppManager', e);
      return {
        'report_timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  /// تنظيف موارد التطبيق
  Future<void> cleanup() async {
    try {
      Logger.shutdown('app_cleanup_started');

      // إيقاف مراقب الأداء
      PerformanceMonitor().stopMonitoring();
      Logger.shutdown('performance_monitor_stopped');

      // تحسين التخزين المؤقت
      await CacheManager().optimize();
      Logger.shutdown('cache_optimized');

      // تسجيل حدث إغلاق التطبيق
      Analytics().logAppClose();
      Logger.shutdown('analytics_logged');

      Logger.shutdown('app_cleanup_completed');
    } catch (e) {
      Logger.error('App cleanup failed', 'AppManager', e);
    }
  }

  /// إعادة تعيين جميع الإحصائيات
  void resetAllStats() {
    try {
      PerformanceMonitor().clearMetrics();
      ErrorHandler().clearErrorHistory();
      AppLifecycleManager().resetStats();
      CacheManager().clear();

      Logger.info('All stats reset', 'AppManager');
    } catch (e) {
      Logger.error('Failed to reset stats', 'AppManager', e);
    }
  }

  /// التحقق من صحة التطبيق
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final results = <String, bool>{};

      // فحص الشبكة
      results['network'] = await NetworkManager().checkInternetConnection();

      // فحص التخزين المؤقت
      final cacheInfo = await CacheManager().getCacheInfo();
      results['cache'] = cacheInfo.isNotEmpty;

      // فحص الأداء
      final performanceStats = PerformanceMonitor().getPerformanceStats();
      results['performance'] = performanceStats.isNotEmpty;

      // فحص الأخطاء
      final errorStats = ErrorHandler().getErrorStats();
      results['errors'] = !ErrorHandler().hasCriticalErrors();

      // حساب النتيجة الإجمالية
      final allHealthy = results.values.every((healthy) => healthy);

      return {
        'timestamp': DateTime.now().toIso8601String(),
        'overall_healthy': allHealthy,
        'checks': results,
      };
    } catch (e) {
      Logger.error('Health check failed', 'AppManager', e);
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'overall_healthy': false,
        'error': e.toString(),
      };
    }
  }

  /// إغلاق مدير التطبيق
  Future<void> dispose() async {
    try {
      Logger.shutdown('app_disposal_started');

      await cleanup();

      // إغلاق جميع المديرين
      PerformanceMonitor().dispose();
      NetworkManager().dispose();
      AppLifecycleManager().dispose();
      ErrorHandler().dispose();

      _isInitialized = false;

      Logger.shutdown('app_disposal_completed');
    } catch (e) {
      Logger.error('App disposal failed', 'AppManager', e);
    }
  }

  /// الحصول على معلومات النظام
  Map<String, dynamic> getSystemInfo() {
    return {
      'platform': defaultTargetPlatform.toString(),
      'is_debug': kDebugMode,
      'is_profile': kProfileMode,
      'is_release': kReleaseMode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// الحصول على معلومات الإصدار
  Map<String, dynamic> getVersionInfo() {
    return {
      'version': '1.0.0',
      'build_number': '1',
      'build_date': DateTime.now().toIso8601String(),
      'app_name': 'AI Vision Chat',
      'description': 'تطبيق الذكاء الاصطناعي المتكامل',
    };
  }
}