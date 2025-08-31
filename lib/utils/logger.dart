import 'package:flutter/foundation.dart';

class Logger {
  static const String _tag = 'AI_VISION_CHAT';
  
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      print('🐛 [${tag ?? _tag}] DEBUG: $message');
    }
  }
  
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      print('ℹ️ [${tag ?? _tag}] INFO: $message');
    }
  }
  
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      print('⚠️ [${tag ?? _tag}] WARNING: $message');
    }
  }
  
  static void error(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [${tag ?? _tag}] ERROR: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
  
  static void api(String endpoint, {String? method, Map<String, dynamic>? data, int? statusCode, String? response}) {
    if (kDebugMode) {
      print('🌐 [${_tag}] API: ${method ?? 'GET'} $endpoint');
      if (data != null) {
        print('Request data: $data');
      }
      if (statusCode != null) {
        print('Status code: $statusCode');
      }
      if (response != null) {
        print('Response: $response');
      }
    }
  }
  
  static void performance(String operation, Duration duration) {
    if (kDebugMode) {
      print('⚡ [${_tag}] PERFORMANCE: $operation took ${duration.inMilliseconds}ms');
    }
  }
  
  static void userAction(String action, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      print('👤 [${_tag}] USER_ACTION: $action');
      if (parameters != null) {
        print('Parameters: $parameters');
      }
    }
  }
  
  static void imageProcessing(String operation, {String? imagePath, int? size}) {
    if (kDebugMode) {
      print('🖼️ [${_tag}] IMAGE: $operation');
      if (imagePath != null) {
        print('Image path: $imagePath');
      }
      if (size != null) {
        print('Image size: ${size} bytes');
      }
    }
  }
  
  static void chat(String message, {bool isUser = true, String? response}) {
    if (kDebugMode) {
      final sender = isUser ? 'USER' : 'AI';
      print('💬 [${_tag}] CHAT: $sender: $message');
      if (response != null) {
        print('AI Response: $response');
      }
    }
  }
  
  static void storage(String operation, {String? key, dynamic value}) {
    if (kDebugMode) {
      print('💾 [${_tag}] STORAGE: $operation');
      if (key != null) {
        print('Key: $key');
      }
      if (value != null) {
        print('Value: $value');
      }
    }
  }
  
  static void permission(String permission, bool granted) {
    if (kDebugMode) {
      final status = granted ? 'GRANTED' : 'DENIED';
      print('🔐 [${_tag}] PERMISSION: $permission - $status');
    }
  }
  
  static void network(String operation, {String? url, int? statusCode, String? error}) {
    if (kDebugMode) {
      print('🌍 [${_tag}] NETWORK: $operation');
      if (url != null) {
        print('URL: $url');
      }
      if (statusCode != null) {
        print('Status: $statusCode');
      }
      if (error != null) {
        print('Error: $error');
      }
    }
  }
  
  static void lifecycle(String event) {
    if (kDebugMode) {
      print('🔄 [${_tag}] LIFECYCLE: $event');
    }
  }
  
  static void memory(String operation, {int? bytes}) {
    if (kDebugMode) {
      print('🧠 [${_tag}] MEMORY: $operation');
      if (bytes != null) {
        print('Bytes: $bytes');
      }
    }
  }
  
  static void cache(String operation, {String? key, bool? hit}) {
    if (kDebugMode) {
      print('📦 [${_tag}] CACHE: $operation');
      if (key != null) {
        print('Key: $key');
      }
      if (hit != null) {
        print('Cache ${hit ? 'HIT' : 'MISS'}');
      }
    }
  }
  
  static void analytics(String event, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      print('📊 [${_tag}] ANALYTICS: $event');
      if (parameters != null) {
        print('Parameters: $parameters');
      }
    }
  }
  
  static void security(String operation, {String? resource, bool? success}) {
    if (kDebugMode) {
      print('🔒 [${_tag}] SECURITY: $operation');
      if (resource != null) {
        print('Resource: $resource');
      }
      if (success != null) {
        print('Success: $success');
      }
    }
  }
  
  static void startup(String phase, [Duration? duration]) {
    if (kDebugMode) {
      print('🚀 [${_tag}] STARTUP: $phase');
      if (duration != null) {
        print('Duration: ${duration.inMilliseconds}ms');
      }
    }
  }
  
  static void shutdown(String phase) {
    if (kDebugMode) {
      print('🛑 [${_tag}] SHUTDOWN: $phase');
    }
  }
}