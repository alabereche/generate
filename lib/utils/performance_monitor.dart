import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'logger.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _activeTimers = {};
  final Map<String, List<int>> _performanceMetrics = {};
  final StreamController<Map<String, dynamic>> _metricsController = StreamController<Map<String, dynamic>>.broadcast();
  
  bool _isMonitoring = false;
  Timer? _monitoringTimer;

  /// Stream للمقاييس
  Stream<Map<String, dynamic>> get metricsStream => _metricsController.stream;

  /// بدء مراقبة الأداء
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(interval, (_) => _collectMetrics());
    
    Logger.performance('performance_monitoring_started', {'interval_seconds': interval.inSeconds});
  }

  /// إيقاف مراقبة الأداء
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    Logger.performance('performance_monitoring_stopped');
  }

  /// بدء قياس أداء عملية معينة
  void startTimer(String operation) {
    if (_activeTimers.containsKey(operation)) {
      Logger.warning('Timer already exists for operation: $operation', 'PerformanceMonitor');
      return;
    }
    
    _activeTimers[operation] = Stopwatch()..start();
    Logger.performance('timer_started', {'operation': operation});
  }

  /// إيقاف قياس أداء عملية معينة
  int? stopTimer(String operation) {
    final timer = _activeTimers.remove(operation);
    if (timer == null) {
      Logger.warning('No timer found for operation: $operation', 'PerformanceMonitor');
      return null;
    }
    
    timer.stop();
    final duration = timer.elapsedMilliseconds;
    
    // حفظ المقياس
    _performanceMetrics.putIfAbsent(operation, () => []);
    _performanceMetrics[operation]!.add(duration);
    
    Logger.performance('timer_stopped', {
      'operation': operation,
      'duration_ms': duration,
    });
    
    return duration;
  }

  /// قياس أداء عملية معينة باستخدام callback
  Future<T> measureOperation<T>(String operation, Future<T> Function() callback) async {
    startTimer(operation);
    try {
      final result = await callback();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }

  /// قياس أداء عملية متزامنة
  T measureSyncOperation<T>(String operation, T Function() callback) {
    startTimer(operation);
    try {
      final result = callback();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }

  /// الحصول على إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _performanceMetrics.entries) {
      final operation = entry.key;
      final metrics = entry.value;
      
      if (metrics.isNotEmpty) {
        final sortedMetrics = List<int>.from(metrics)..sort();
        final count = metrics.length;
        final total = metrics.reduce((a, b) => a + b);
        final average = total / count;
        final min = sortedMetrics.first;
        final max = sortedMetrics.last;
        final median = sortedMetrics[count ~/ 2];
        
        stats[operation] = {
          'count': count,
          'total_ms': total,
          'average_ms': average,
          'min_ms': min,
          'max_ms': max,
          'median_ms': median,
          'last_measurement': metrics.last,
        };
      }
    }
    
    return stats;
  }

  /// الحصول على معلومات الذاكرة
  Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      final processInfo = ProcessInfo.currentProcess;
      final memoryUsage = await processInfo.memoryUsage;
      
      return {
        'resident_memory_mb': (memoryUsage.resident / (1024 * 1024)).toStringAsFixed(2),
        'virtual_memory_mb': (memoryUsage.virtual / (1024 * 1024)).toStringAsFixed(2),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to get memory info', 'PerformanceMonitor', e);
      return {};
    }
  }

  /// الحصول على معلومات النظام
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final processInfo = ProcessInfo.currentProcess;
      
      return {
        'pid': processInfo.pid,
        'start_time': processInfo.startTime.toIso8601String(),
        'max_rss_mb': (processInfo.maxRss / (1024 * 1024)).toStringAsFixed(2),
        'cpu_count': Platform.numberOfProcessors,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'local_hostname': Platform.localHostname,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to get system info', 'PerformanceMonitor', e);
      return {};
    }
  }

  /// جمع المقاييس
  void _collectMetrics() async {
    try {
      final performanceStats = getPerformanceStats();
      final memoryInfo = await getMemoryInfo();
      final systemInfo = await getSystemInfo();
      
      final metrics = {
        'timestamp': DateTime.now().toIso8601String(),
        'performance': performanceStats,
        'memory': memoryInfo,
        'system': systemInfo,
      };
      
      _metricsController.add(metrics);
      
      Logger.performance('metrics_collected', {
        'operations_count': performanceStats.length,
        'memory_usage_mb': memoryInfo['resident_memory_mb'],
      });
    } catch (e) {
      Logger.error('Failed to collect metrics', 'PerformanceMonitor', e);
    }
  }

  /// الحصول على تقرير شامل عن الأداء
  Future<Map<String, dynamic>> getComprehensiveReport() async {
    try {
      final performanceStats = getPerformanceStats();
      final memoryInfo = await getMemoryInfo();
      final systemInfo = await getSystemInfo();
      
      // حساب الإحصائيات الإجمالية
      int totalOperations = 0;
      int totalDuration = 0;
      double overallAverage = 0;
      
      for (final stats in performanceStats.values) {
        totalOperations += stats['count'] as int;
        totalDuration += stats['total_ms'] as int;
      }
      
      if (totalOperations > 0) {
        overallAverage = totalDuration / totalOperations;
      }
      
      return {
        'report_timestamp': DateTime.now().toIso8601String(),
        'summary': {
          'total_operations': totalOperations,
          'total_duration_ms': totalDuration,
          'overall_average_ms': overallAverage,
          'monitored_operations': performanceStats.length,
        },
        'performance': performanceStats,
        'memory': memoryInfo,
        'system': systemInfo,
      };
    } catch (e) {
      Logger.error('Failed to get comprehensive report', 'PerformanceMonitor', e);
      return {};
    }
  }

  /// مسح جميع المقاييس
  void clearMetrics() {
    _performanceMetrics.clear();
    Logger.performance('metrics_cleared');
  }

  /// الحصول على المقاييس لعملية معينة
  List<int> getMetricsForOperation(String operation) {
    return _performanceMetrics[operation] ?? [];
  }

  /// التحقق من وجود مقاييس لعملية معينة
  bool hasMetricsForOperation(String operation) {
    return _performanceMetrics.containsKey(operation) && _performanceMetrics[operation]!.isNotEmpty;
  }

  /// الحصول على آخر قياس لعملية معينة
  int? getLastMeasurement(String operation) {
    final metrics = _performanceMetrics[operation];
    return metrics?.isNotEmpty == true ? metrics!.last : null;
  }

  /// الحصول على متوسط الأداء لعملية معينة
  double? getAverageForOperation(String operation) {
    final metrics = _performanceMetrics[operation];
    if (metrics?.isNotEmpty != true) return null;
    
    final total = metrics!.reduce((a, b) => a + b);
    return total / metrics.length;
  }

  /// الحصول على أفضل أداء لعملية معينة
  int? getBestPerformance(String operation) {
    final metrics = _performanceMetrics[operation];
    return metrics?.isNotEmpty == true ? metrics!.reduce((a, b) => a < b ? a : b) : null;
  }

  /// الحصول على أسوأ أداء لعملية معينة
  int? getWorstPerformance(String operation) {
    final metrics = _performanceMetrics[operation];
    return metrics?.isNotEmpty == true ? metrics!.reduce((a, b) => a > b ? a : b) : null;
  }

  /// إغلاق مراقب الأداء
  void dispose() {
    stopMonitoring();
    _metricsController.close();
    Logger.performance('performance_monitor_disposed');
  }
}