import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isConnected = false;
  ConnectivityResult? _lastConnectivityResult;

  /// Stream لحالة الاتصال
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// الحصول على حالة الاتصال الحالية
  bool get isConnected => _isConnected;

  /// تهيئة مدير الشبكة
  Future<void> initialize() async {
    try {
      // التحقق من حالة الاتصال الأولية
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // الاستماع لتغييرات الاتصال
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
      
      Logger.network('network_manager_initialized', {'status': _isConnected});
    } catch (e) {
      Logger.error('Failed to initialize network manager', 'NetworkManager', e);
    }
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _lastConnectivityResult = result;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        _isConnected = true;
        break;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        _isConnected = false;
        break;
    }

    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
      Logger.network('connection_status_changed', {
        'previous': wasConnected,
        'current': _isConnected,
        'type': result.toString(),
      });
    }
  }

  /// التحقق من الاتصال بالإنترنت
  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      Logger.network('internet_connection_check', {'connected': hasConnection});
      return hasConnection;
    } on SocketException catch (e) {
      Logger.network('internet_connection_failed', {'error': e.message});
      return false;
    }
  }

  /// الحصول على نوع الاتصال
  Future<String> getConnectionType() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.toString().split('.').last;
    } catch (e) {
      Logger.error('Failed to get connection type', 'NetworkManager', e);
      return 'unknown';
    }
  }

  /// الحصول على معلومات الشبكة
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasInternet = await checkInternetConnection();
      
      return {
        'connectivity_type': connectivityResult.toString().split('.').last,
        'has_internet': hasInternet,
        'is_connected': _isConnected,
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to get network info', 'NetworkManager', e);
      return {};
    }
  }

  /// التحقق من سرعة الاتصال
  Future<Map<String, dynamic>> checkConnectionSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // اختبار الاتصال بـ Google DNS
      final result = await InternetAddress.lookup('8.8.8.8');
      stopwatch.stop();
      
      final pingTime = stopwatch.elapsedMilliseconds;
      String speedCategory;
      
      if (pingTime < 50) {
        speedCategory = 'excellent';
      } else if (pingTime < 100) {
        speedCategory = 'good';
      } else if (pingTime < 200) {
        speedCategory = 'fair';
      } else {
        speedCategory = 'poor';
      }
      
      Logger.network('connection_speed_check', {
        'ping_ms': pingTime,
        'category': speedCategory,
      });
      
      return {
        'ping_ms': pingTime,
        'speed_category': speedCategory,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to check connection speed', 'NetworkManager', e);
      return {
        'ping_ms': -1,
        'speed_category': 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// اختبار الاتصال بخادم معين
  Future<bool> testConnection(String host, {int port = 80, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      await socket.close();
      
      Logger.network('connection_test_success', {'host': host, 'port': port});
      return true;
    } catch (e) {
      Logger.network('connection_test_failed', {
        'host': host,
        'port': port,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// الحصول على عنوان IP المحلي
  Future<String?> getLocalIPAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.address.startsWith('127.')) {
            Logger.network('local_ip_found', {'ip': addr.address});
            return addr.address;
          }
        }
      }
      
      Logger.network('local_ip_not_found');
      return null;
    } catch (e) {
      Logger.error('Failed to get local IP address', 'NetworkManager', e);
      return null;
    }
  }

  /// مراقبة جودة الاتصال
  Future<Map<String, dynamic>> monitorConnectionQuality({Duration duration = const Duration(seconds: 30)}) async {
    try {
      final stopwatch = Stopwatch()..start();
      int successfulPings = 0;
      int totalPings = 0;
      final pingTimes = <int>[];
      
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (stopwatch.elapsed >= duration) {
          timer.cancel();
          return;
        }
        
        totalPings++;
        final pingStopwatch = Stopwatch()..start();
        
        try {
          await InternetAddress.lookup('google.com');
          pingStopwatch.stop();
          successfulPings++;
          pingTimes.add(pingStopwatch.elapsedMilliseconds);
        } catch (e) {
          // Ping failed
        }
      });
      
      // انتظار انتهاء المدة
      await Future.delayed(duration);
      timer.cancel();
      stopwatch.stop();
      
      final successRate = totalPings > 0 ? (successfulPings / totalPings) * 100 : 0;
      final averagePing = pingTimes.isNotEmpty 
          ? pingTimes.reduce((a, b) => a + b) / pingTimes.length 
          : 0;
      
      Logger.network('connection_quality_monitoring', {
        'duration_seconds': duration.inSeconds,
        'success_rate': successRate,
        'average_ping': averagePing,
        'total_pings': totalPings,
        'successful_pings': successfulPings,
      });
      
      return {
        'duration_seconds': duration.inSeconds,
        'success_rate': successRate,
        'average_ping_ms': averagePing,
        'total_pings': totalPings,
        'successful_pings': successfulPings,
        'ping_times': pingTimes,
      };
    } catch (e) {
      Logger.error('Failed to monitor connection quality', 'NetworkManager', e);
      return {};
    }
  }

  /// إعادة تعيين حالة الاتصال
  Future<void> resetConnectionStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      Logger.network('connection_status_reset', {'status': _isConnected});
    } catch (e) {
      Logger.error('Failed to reset connection status', 'NetworkManager', e);
    }
  }

  /// إغلاق مدير الشبكة
  void dispose() {
    _connectionStatusController.close();
    Logger.network('network_manager_disposed');
  }

  /// الحصول على تقرير شامل عن الشبكة
  Future<Map<String, dynamic>> getComprehensiveReport() async {
    try {
      final networkInfo = await getNetworkInfo();
      final speedInfo = await checkConnectionSpeed();
      final localIP = await getLocalIPAddress();
      
      return {
        ...networkInfo,
        ...speedInfo,
        'local_ip': localIP,
        'report_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Failed to get comprehensive network report', 'NetworkManager', e);
      return {};
    }
  }
}