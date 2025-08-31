import 'package:flutter/foundation.dart';
import 'logger.dart';

class Analytics {
  static final Analytics _instance = Analytics._internal();
  factory Analytics() => _instance;
  Analytics._internal();

  bool _isEnabled = false;

  /// تفعيل أو إلغاء تفعيل التحليلات
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    Logger.analytics('analytics_enabled', {'enabled': enabled});
  }

  /// تسجيل حدث تطبيق مفتوح
  void logAppOpen() {
    if (!_isEnabled) return;
    Logger.analytics('app_open');
  }

  /// تسجيل حدث تطبيق مغلق
  void logAppClose() {
    if (!_isEnabled) return;
    Logger.analytics('app_close');
  }

  /// تسجيل حدث تحليل صورة
  void logImageAnalysis({String? source, bool? success, String? error}) {
    if (!_isEnabled) return;
    Logger.analytics('image_analysis', {
      'source': source ?? 'unknown',
      'success': success ?? false,
      'error': error,
    });
  }

  /// تسجيل حدث توليد صورة
  void logImageGeneration({String? prompt, bool? success, String? error}) {
    if (!_isEnabled) return;
    Logger.analytics('image_generation', {
      'prompt_length': prompt?.length ?? 0,
      'success': success ?? false,
      'error': error,
    });
  }

  /// تسجيل حدث إرسال رسالة في الدردشة
  void logChatMessage({String? message, bool? success, String? error}) {
    if (!_isEnabled) return;
    Logger.analytics('chat_message', {
      'message_length': message?.length ?? 0,
      'success': success ?? false,
      'error': error,
    });
  }

  /// تسجيل حدث حفظ صورة
  void logImageSave({String? source, bool? success, String? error}) {
    if (!_isEnabled) return;
    Logger.analytics('image_save', {
      'source': source ?? 'unknown',
      'success': success ?? false,
      'error': error,
    });
  }

  /// تسجيل حدث مشاركة صورة
  void logImageShare({String? source, bool? success, String? error}) {
    if (!_isEnabled) return;
    Logger.analytics('image_share', {
      'source': source ?? 'unknown',
      'success': success ?? false,
      'error': error,
    });
  }

  /// تسجيل حدث تغيير الوضع (داكن/نهاري)
  void logThemeChange({bool? isDark}) {
    if (!_isEnabled) return;
    Logger.analytics('theme_change', {
      'is_dark': isDark ?? false,
    });
  }

  /// تسجيل حدث تغيير اللغة
  void logLanguageChange({String? language}) {
    if (!_isEnabled) return;
    Logger.analytics('language_change', {
      'language': language ?? 'unknown',
    });
  }

  /// تسجيل حدث مسح المحادثة
  void logChatClear({int? messageCount}) {
    if (!_isEnabled) return;
    Logger.analytics('chat_clear', {
      'message_count': messageCount ?? 0,
    });
  }

  /// تسجيل حدث خطأ في التطبيق
  void logError({String? error, String? screen, String? action}) {
    if (!_isEnabled) return;
    Logger.analytics('app_error', {
      'error': error,
      'screen': screen,
      'action': action,
    });
  }

  /// تسجيل حدث أداء
  void logPerformance({String? operation, int? durationMs}) {
    if (!_isEnabled) return;
    Logger.analytics('performance', {
      'operation': operation,
      'duration_ms': durationMs,
    });
  }

  /// تسجيل حدث استخدام الميزات
  void logFeatureUsage({String? feature, Map<String, dynamic>? parameters}) {
    if (!_isEnabled) return;
    final data = <String, dynamic>{
      'feature': feature,
    };
    if (parameters != null) {
      data.addAll(parameters);
    }
    Logger.analytics('feature_usage', data);
  }

  /// تسجيل حدث تفاعل المستخدم
  void logUserInteraction({String? action, String? screen, Map<String, dynamic>? parameters}) {
    if (!_isEnabled) return;
    final data = <String, dynamic>{
      'action': action,
      'screen': screen,
    };
    if (parameters != null) {
      data.addAll(parameters);
    }
    Logger.analytics('user_interaction', data);
  }

  /// تسجيل حدث جلسة المستخدم
  void logSession({String? event, Duration? duration}) {
    if (!_isEnabled) return;
    Logger.analytics('session', {
      'event': event,
      'duration_seconds': duration?.inSeconds,
    });
  }

  /// تسجيل حدث إعدادات التطبيق
  void logSettings({String? setting, dynamic value}) {
    if (!_isEnabled) return;
    Logger.analytics('settings_change', {
      'setting': setting,
      'value': value.toString(),
    });
  }

  /// تسجيل حدث استخدام الذاكرة
  void logMemoryUsage({int? bytes, String? operation}) {
    if (!_isEnabled) return;
    Logger.analytics('memory_usage', {
      'bytes': bytes,
      'operation': operation,
    });
  }

  /// تسجيل حدث استخدام الشبكة
  void logNetworkUsage({String? endpoint, int? statusCode, int? responseTime}) {
    if (!_isEnabled) return;
    Logger.analytics('network_usage', {
      'endpoint': endpoint,
      'status_code': statusCode,
      'response_time_ms': responseTime,
    });
  }

  /// تسجيل حدث استخدام التخزين
  void logStorageUsage({String? operation, int? bytes, String? fileType}) {
    if (!_isEnabled) return;
    Logger.analytics('storage_usage', {
      'operation': operation,
      'bytes': bytes,
      'file_type': fileType,
    });
  }

  /// تسجيل حدث أمان
  void logSecurity({String? event, bool? success, String? resource}) {
    if (!_isEnabled) return;
    Logger.analytics('security', {
      'event': event,
      'success': success,
      'resource': resource,
    });
  }

  /// تسجيل حدث إمكانية الوصول
  void logAccessibility({String? feature, bool? enabled}) {
    if (!_isEnabled) return;
    Logger.analytics('accessibility', {
      'feature': feature,
      'enabled': enabled,
    });
  }

  /// تسجيل حدث تخصيص
  void logCustomization({String? element, String? value}) {
    if (!_isEnabled) return;
    Logger.analytics('customization', {
      'element': element,
      'value': value,
    });
  }

  /// تسجيل حدث تقييم التطبيق
  void logAppRating({int? rating, String? feedback}) {
    if (!_isEnabled) return;
    Logger.analytics('app_rating', {
      'rating': rating,
      'feedback_length': feedback?.length ?? 0,
    });
  }

  /// تسجيل حدث مشاركة التطبيق
  void logAppShare({String? platform}) {
    if (!_isEnabled) return;
    Logger.analytics('app_share', {
      'platform': platform,
    });
  }

  /// تسجيل حدث تحديث التطبيق
  void logAppUpdate({String? version, bool? success}) {
    if (!_isEnabled) return;
    Logger.analytics('app_update', {
      'version': version,
      'success': success,
    });
  }

  /// تسجيل حدث استعادة البيانات
  void logDataRestore({String? source, bool? success, int? itemsCount}) {
    if (!_isEnabled) return;
    Logger.analytics('data_restore', {
      'source': source,
      'success': success,
      'items_count': itemsCount,
    });
  }

  /// تسجيل حدث نسخ احتياطي للبيانات
  void logDataBackup({String? destination, bool? success, int? itemsCount}) {
    if (!_isEnabled) return;
    Logger.analytics('data_backup', {
      'destination': destination,
      'success': success,
      'items_count': itemsCount,
    });
  }
}