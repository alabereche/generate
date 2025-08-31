import 'dart:async';
import 'package:flutter/widgets.dart';
import 'logger.dart';

class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  final StreamController<AppLifecycleState> _lifecycleController = StreamController<AppLifecycleState>.broadcast();
  
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  DateTime? _lastPauseTime;
  DateTime? _lastResumeTime;
  Duration _totalActiveTime = Duration.zero;
  int _sessionCount = 0;

  /// Stream لحالة دورة الحياة
  Stream<AppLifecycleState> get lifecycleStream => _lifecycleController.stream;

  /// الحصول على الحالة الحالية
  AppLifecycleState get currentState => _currentState;

  /// الحصول على الوقت الإجمالي النشط
  Duration get totalActiveTime => _totalActiveTime;

  /// الحصول على عدد الجلسات
  int get sessionCount => _sessionCount;

  /// تهيئة مدير دورة الحياة
  void initialize() {
    Logger.lifecycle('app_lifecycle_manager_initialized');
  }

  /// تحديث حالة دورة الحياة
  void updateState(AppLifecycleState newState) {
    final previousState = _currentState;
    _currentState = newState;

    switch (newState) {
      case AppLifecycleState.resumed:
        _handleResumed();
        break;
      case AppLifecycleState.inactive:
        _handleInactive();
        break;
      case AppLifecycleState.paused:
        _handlePaused();
        break;
      case AppLifecycleState.detached:
        _handleDetached();
        break;
      case AppLifecycleState.hidden:
        _handleHidden();
        break;
    }

    _lifecycleController.add(newState);
    
    Logger.lifecycle('state_changed', {
      'previous': previousState.toString(),
      'current': newState.toString(),
    });
  }

  /// معالجة حالة الاستئناف
  void _handleResumed() {
    _lastResumeTime = DateTime.now();
    _sessionCount++;
    
    Logger.lifecycle('app_resumed', {
      'session_count': _sessionCount,
      'timestamp': _lastResumeTime?.toIso8601String(),
    });
  }

  /// معالجة حالة عدم النشاط
  void _handleInactive() {
    Logger.lifecycle('app_inactive');
  }

  /// معالجة حالة الإيقاف المؤقت
  void _handlePaused() {
    _lastPauseTime = DateTime.now();
    
    if (_lastResumeTime != null) {
      final sessionDuration = _lastPauseTime!.difference(_lastResumeTime!);
      _totalActiveTime += sessionDuration;
      
      Logger.lifecycle('app_paused', {
        'session_duration_seconds': sessionDuration.inSeconds,
        'total_active_time_seconds': _totalActiveTime.inSeconds,
      });
    }
  }

  /// معالجة حالة الانفصال
  void _handleDetached() {
    Logger.lifecycle('app_detached');
  }

  /// معالجة حالة الإخفاء
  void _handleHidden() {
    Logger.lifecycle('app_hidden');
  }

  /// الحصول على مدة الجلسة الحالية
  Duration? getCurrentSessionDuration() {
    if (_lastResumeTime == null) return null;
    
    final now = DateTime.now();
    return now.difference(_lastResumeTime!);
  }

  /// الحصول على مدة آخر جلسة
  Duration? getLastSessionDuration() {
    if (_lastResumeTime == null || _lastPauseTime == null) return null;
    
    return _lastPauseTime!.difference(_lastResumeTime!);
  }

  /// الحصول على متوسط مدة الجلسة
  Duration getAverageSessionDuration() {
    if (_sessionCount == 0) return Duration.zero;
    
    return Duration(milliseconds: _totalActiveTime.inMilliseconds ~/ _sessionCount);
  }

  /// الحصول على معلومات الجلسة
  Map<String, dynamic> getSessionInfo() {
    return {
      'current_state': _currentState.toString(),
      'session_count': _sessionCount,
      'total_active_time_seconds': _totalActiveTime.inSeconds,
      'average_session_duration_seconds': getAverageSessionDuration().inSeconds,
      'current_session_duration_seconds': getCurrentSessionDuration()?.inSeconds,
      'last_session_duration_seconds': getLastSessionDuration()?.inSeconds,
      'last_resume_time': _lastResumeTime?.toIso8601String(),
      'last_pause_time': _lastPauseTime?.toIso8601String(),
    };
  }

  /// إعادة تعيين الإحصائيات
  void resetStats() {
    _totalActiveTime = Duration.zero;
    _sessionCount = 0;
    _lastPauseTime = null;
    _lastResumeTime = null;
    
    Logger.lifecycle('stats_reset');
  }

  /// التحقق من أن التطبيق نشط
  bool get isActive {
    return _currentState == AppLifecycleState.resumed;
  }

  /// التحقق من أن التطبيق في الخلفية
  bool get isBackgrounded {
    return _currentState == AppLifecycleState.paused || 
           _currentState == AppLifecycleState.inactive ||
           _currentState == AppLifecycleState.hidden;
  }

  /// التحقق من أن التطبيق منفصل
  bool get isDetached {
    return _currentState == AppLifecycleState.detached;
  }

  /// الحصول على تقرير شامل عن دورة الحياة
  Map<String, dynamic> getComprehensiveReport() {
    return {
      'report_timestamp': DateTime.now().toIso8601String(),
      'current_state': _currentState.toString(),
      'session_info': getSessionInfo(),
      'is_active': isActive,
      'is_backgrounded': isBackgrounded,
      'is_detached': isDetached,
    };
  }

  /// إغلاق مدير دورة الحياة
  void dispose() {
    _lifecycleController.close();
    Logger.lifecycle('app_lifecycle_manager_disposed');
  }
}

/// مدير دورة الحياة للـ Widget
class AppLifecycleWidget extends StatefulWidget {
  final Widget child;
  final Function(AppLifecycleState)? onStateChanged;

  const AppLifecycleWidget({
    super.key,
    required this.child,
    this.onStateChanged,
  });

  @override
  State<AppLifecycleWidget> createState() => _AppLifecycleWidgetState();
}

class _AppLifecycleWidgetState extends State<AppLifecycleWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLifecycleManager().initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLifecycleManager().updateState(state);
    widget.onStateChanged?.call(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}