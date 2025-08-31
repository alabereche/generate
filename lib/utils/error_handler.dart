import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final List<ErrorInfo> _errorHistory = [];
  final StreamController<ErrorInfo> _errorController = StreamController<ErrorInfo>.broadcast();
  
  bool _isInitialized = false;
  int _maxErrorHistory = 100;

  /// Stream للأخطاء
  Stream<ErrorInfo> get errorStream => _errorController.stream;

  /// تهيئة معالج الأخطاء
  void initialize({int maxHistory = 100}) {
    if (_isInitialized) return;
    
    _maxErrorHistory = maxHistory;
    _isInitialized = true;
    
    // التقاط الأخطاء غير المعالجة
    FlutterError.onError = _handleFlutterError;
    
    Logger.info('Error handler initialized', 'ErrorHandler');
  }

  /// معالجة خطأ Flutter
  void _handleFlutterError(FlutterErrorDetails details) {
    final errorInfo = ErrorInfo(
      message: details.exception.toString(),
      stackTrace: details.stack,
      context: 'Flutter Error',
      severity: ErrorSeverity.error,
      timestamp: DateTime.now(),
      additionalData: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
    
    _addError(errorInfo);
  }

  /// إضافة خطأ جديد
  void addError(
    String message, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? additionalData,
  }) {
    final errorInfo = ErrorInfo(
      message: message,
      stackTrace: stackTrace,
      context: context ?? 'Unknown',
      severity: severity,
      timestamp: DateTime.now(),
      additionalData: additionalData,
    );
    
    _addError(errorInfo);
  }

  /// إضافة خطأ API
  void addApiError(
    String endpoint,
    int? statusCode,
    String message, {
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) {
    addError(
      'API Error: $message',
      context: 'API Request',
      severity: ErrorSeverity.error,
      additionalData: {
        'endpoint': endpoint,
        'status_code': statusCode,
        'request_data': requestData,
        'response_data': responseData,
      },
    );
  }

  /// إضافة خطأ شبكة
  void addNetworkError(
    String operation,
    String message, {
    String? url,
    int? statusCode,
  }) {
    addError(
      'Network Error: $message',
      context: 'Network',
      severity: ErrorSeverity.error,
      additionalData: {
        'operation': operation,
        'url': url,
        'status_code': statusCode,
      },
    );
  }

  /// إضافة خطأ تخزين
  void addStorageError(
    String operation,
    String message, {
    String? filePath,
    int? fileSize,
  }) {
    addError(
      'Storage Error: $message',
      context: 'Storage',
      severity: ErrorSeverity.error,
      additionalData: {
        'operation': operation,
        'file_path': filePath,
        'file_size': fileSize,
      },
    );
  }

  /// إضافة خطأ معالجة الصور
  void addImageProcessingError(
    String operation,
    String message, {
    String? imagePath,
    int? imageSize,
  }) {
    addError(
      'Image Processing Error: $message',
      context: 'Image Processing',
      severity: ErrorSeverity.error,
      additionalData: {
        'operation': operation,
        'image_path': imagePath,
        'image_size': imageSize,
      },
    );
  }

  /// إضافة خطأ أذونات
  void addPermissionError(
    String permission,
    String message, {
    bool? isGranted,
  }) {
    addError(
      'Permission Error: $message',
      context: 'Permissions',
      severity: ErrorSeverity.warning,
      additionalData: {
        'permission': permission,
        'is_granted': isGranted,
      },
    );
  }

  /// إضافة خطأ تحقق
  void addValidationError(
    String field,
    String message, {
    String? value,
  }) {
    addError(
      'Validation Error: $message',
      context: 'Validation',
      severity: ErrorSeverity.warning,
      additionalData: {
        'field': field,
        'value': value,
      },
    );
  }

  /// إضافة خطأ أمان
  void addSecurityError(
    String operation,
    String message, {
    String? resource,
    bool? success,
  }) {
    addError(
      'Security Error: $message',
      context: 'Security',
      severity: ErrorSeverity.critical,
      additionalData: {
        'operation': operation,
        'resource': resource,
        'success': success,
      },
    );
  }

  /// إضافة خطأ داخلي
  void _addError(ErrorInfo errorInfo) {
    _errorHistory.add(errorInfo);
    
    // الحفاظ على الحد الأقصى للتاريخ
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
    
    // إرسال الخطأ عبر Stream
    _errorController.add(errorInfo);
    
    // تسجيل الخطأ
    Logger.error(
      errorInfo.message,
      errorInfo.context,
      errorInfo.stackTrace,
    );
  }

  /// الحصول على تاريخ الأخطاء
  List<ErrorInfo> getErrorHistory() {
    return List.unmodifiable(_errorHistory);
  }

  /// الحصول على الأخطاء حسب الشدة
  List<ErrorInfo> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }

  /// الحصول على الأخطاء حسب السياق
  List<ErrorInfo> getErrorsByContext(String context) {
    return _errorHistory.where((error) => error.context == context).toList();
  }

  /// الحصول على الأخطاء في فترة زمنية معينة
  List<ErrorInfo> getErrorsInTimeRange(DateTime start, DateTime end) {
    return _errorHistory
        .where((error) => error.timestamp.isAfter(start) && error.timestamp.isBefore(end))
        .toList();
  }

  /// الحصول على إحصائيات الأخطاء
  Map<String, dynamic> getErrorStats() {
    final totalErrors = _errorHistory.length;
    final errorsBySeverity = <ErrorSeverity, int>{};
    final errorsByContext = <String, int>{};
    
    for (final error in _errorHistory) {
      errorsBySeverity[error.severity] = (errorsBySeverity[error.severity] ?? 0) + 1;
      errorsByContext[error.context] = (errorsByContext[error.context] ?? 0) + 1;
    }
    
    return {
      'total_errors': totalErrors,
      'errors_by_severity': errorsBySeverity.map((key, value) => MapEntry(key.toString(), value)),
      'errors_by_context': errorsByContext,
      'last_error_time': _errorHistory.isNotEmpty ? _errorHistory.last.timestamp.toIso8601String() : null,
      'first_error_time': _errorHistory.isNotEmpty ? _errorHistory.first.timestamp.toIso8601String() : null,
    };
  }

  /// مسح تاريخ الأخطاء
  void clearErrorHistory() {
    _errorHistory.clear();
    Logger.info('Error history cleared', 'ErrorHandler');
  }

  /// الحصول على آخر خطأ
  ErrorInfo? getLastError() {
    return _errorHistory.isNotEmpty ? _errorHistory.last : null;
  }

  /// التحقق من وجود أخطاء حرجة
  bool hasCriticalErrors() {
    return _errorHistory.any((error) => error.severity == ErrorSeverity.critical);
  }

  /// الحصول على عدد الأخطاء الحرجة
  int getCriticalErrorCount() {
    return _errorHistory.where((error) => error.severity == ErrorSeverity.critical).length;
  }

  /// الحصول على تقرير شامل عن الأخطاء
  Map<String, dynamic> getComprehensiveReport() {
    final stats = getErrorStats();
    final recentErrors = _errorHistory.take(10).toList();
    
    return {
      'report_timestamp': DateTime.now().toIso8601String(),
      'stats': stats,
      'recent_errors': recentErrors.map((error) => error.toMap()).toList(),
      'has_critical_errors': hasCriticalErrors(),
      'critical_error_count': getCriticalErrorCount(),
    };
  }

  /// إغلاق معالج الأخطاء
  void dispose() {
    _errorController.close();
    Logger.info('Error handler disposed', 'ErrorHandler');
  }
}

/// معلومات الخطأ
class ErrorInfo {
  final String message;
  final StackTrace? stackTrace;
  final String context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  ErrorInfo({
    required this.message,
    this.stackTrace,
    required this.context,
    required this.severity,
    required this.timestamp,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'context': context,
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'additional_data': additionalData,
    };
  }

  @override
  String toString() {
    return 'ErrorInfo(message: $message, context: $context, severity: $severity, timestamp: $timestamp)';
  }
}

/// شدة الخطأ
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}