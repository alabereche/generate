import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'logger.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration _cacheExpiration = Duration(days: 7);
  
  Directory? _cacheDirectory;
  final Map<String, DateTime> _cacheTimestamps = {};

  /// تهيئة مدير التخزين المؤقت
  Future<void> initialize() async {
    try {
      _cacheDirectory = await getTemporaryDirectory();
      await _cleanupExpiredCache();
      Logger.cache('cache_initialized', {'path': _cacheDirectory?.path});
    } catch (e) {
      Logger.error('Failed to initialize cache', 'CacheManager', e);
    }
  }

  /// إنشاء مفتاح فريد للملف
  String _generateKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// حفظ بيانات في التخزين المؤقت
  Future<bool> set(String key, Uint8List data, {String? extension}) async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final fileName = extension != null ? '$key$extension' : key;
      final file = File('${_cacheDirectory!.path}/$fileName');
      
      await file.writeAsBytes(data);
      _cacheTimestamps[key] = DateTime.now();
      
      Logger.cache('cache_set', {'key': key, 'size': data.length});
      return true;
    } catch (e) {
      Logger.error('Failed to set cache', 'CacheManager', e);
      return false;
    }
  }

  /// حفظ صورة في التخزين المؤقت
  Future<bool> setImage(String url, Uint8List imageData) async {
    final key = _generateKey(url);
    return await set(key, imageData, extension: '.jpg');
  }

  /// حفظ نص في التخزين المؤقت
  Future<bool> setText(String key, String text) async {
    final data = utf8.encode(text);
    return await set(key, Uint8List.fromList(data));
  }

  /// الحصول على بيانات من التخزين المؤقت
  Future<Uint8List?> get(String key, {String? extension}) async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final fileName = extension != null ? '$key$extension' : key;
      final file = File('${_cacheDirectory!.path}/$fileName');
      
      if (!await file.exists()) {
        Logger.cache('cache_miss', {'key': key});
        return null;
      }

      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) > _cacheExpiration) {
        await file.delete();
        _cacheTimestamps.remove(key);
        Logger.cache('cache_expired', {'key': key});
        return null;
      }

      final data = await file.readAsBytes();
      Logger.cache('cache_hit', {'key': key, 'size': data.length});
      return data;
    } catch (e) {
      Logger.error('Failed to get cache', 'CacheManager', e);
      return null;
    }
  }

  /// الحصول على صورة من التخزين المؤقت
  Future<Uint8List?> getImage(String url) async {
    final key = _generateKey(url);
    return await get(key, extension: '.jpg');
  }

  /// الحصول على نص من التخزين المؤقت
  Future<String?> getText(String key) async {
    final data = await get(key);
    if (data != null) {
      return utf8.decode(data);
    }
    return null;
  }

  /// التحقق من وجود مفتاح في التخزين المؤقت
  Future<bool> has(String key, {String? extension}) async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final fileName = extension != null ? '$key$extension' : key;
      final file = File('${_cacheDirectory!.path}/$fileName');
      
      if (!await file.exists()) return false;

      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) > _cacheExpiration) {
        await file.delete();
        _cacheTimestamps.remove(key);
        return false;
      }

      return true;
    } catch (e) {
      Logger.error('Failed to check cache', 'CacheManager', e);
      return false;
    }
  }

  /// التحقق من وجود صورة في التخزين المؤقت
  Future<bool> hasImage(String url) async {
    final key = _generateKey(url);
    return await has(key, extension: '.jpg');
  }

  /// حذف مفتاح من التخزين المؤقت
  Future<bool> remove(String key, {String? extension}) async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final fileName = extension != null ? '$key$extension' : key;
      final file = File('${_cacheDirectory!.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
        _cacheTimestamps.remove(key);
        Logger.cache('cache_removed', {'key': key});
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to remove cache', 'CacheManager', e);
      return false;
    }
  }

  /// حذف صورة من التخزين المؤقت
  Future<bool> removeImage(String url) async {
    final key = _generateKey(url);
    return await remove(key, extension: '.jpg');
  }

  /// مسح جميع التخزين المؤقت
  Future<bool> clear() async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final files = _cacheDirectory!.listSync();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      
      _cacheTimestamps.clear();
      Logger.cache('cache_cleared');
      return true;
    } catch (e) {
      Logger.error('Failed to clear cache', 'CacheManager', e);
      return false;
    }
  }

  /// الحصول على حجم التخزين المؤقت
  Future<int> getSize() async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      int totalSize = 0;
      final files = _cacheDirectory!.listSync();
      
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      Logger.error('Failed to get cache size', 'CacheManager', e);
      return 0;
    }
  }

  /// الحصول على عدد الملفات في التخزين المؤقت
  Future<int> getFileCount() async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final files = _cacheDirectory!.listSync();
      return files.where((file) => file is File).length;
    } catch (e) {
      Logger.error('Failed to get cache file count', 'CacheManager', e);
      return 0;
    }
  }

  /// تنظيف التخزين المؤقت منتهي الصلاحية
  Future<void> _cleanupExpiredCache() async {
    try {
      if (_cacheDirectory == null) await initialize();
      
      final files = _cacheDirectory!.listSync();
      final now = DateTime.now();
      
      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final key = fileName.split('.').first;
          
          final timestamp = _cacheTimestamps[key];
          if (timestamp != null && now.difference(timestamp) > _cacheExpiration) {
            await file.delete();
            _cacheTimestamps.remove(key);
            Logger.cache('cache_cleanup_expired', {'key': key});
          }
        }
      }
    } catch (e) {
      Logger.error('Failed to cleanup expired cache', 'CacheManager', e);
    }
  }

  /// تنظيف التخزين المؤقت عند تجاوز الحد الأقصى
  Future<void> _cleanupOversizedCache() async {
    try {
      final currentSize = await getSize();
      if (currentSize <= _maxCacheSize) return;

      final files = _cacheDirectory!.listSync();
      final fileInfos = <MapEntry<File, DateTime>>[];

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          final key = fileName.split('.').first;
          final timestamp = _cacheTimestamps[key] ?? DateTime.now();
          fileInfos.add(MapEntry(file, timestamp));
        }
      }

      // ترتيب الملفات حسب التاريخ (الأقدم أولاً)
      fileInfos.sort((a, b) => a.value.compareTo(b.value));

      int sizeToRemove = currentSize - _maxCacheSize;
      for (final entry in fileInfos) {
        if (sizeToRemove <= 0) break;
        
        final fileSize = await entry.key.length();
        await entry.key.delete();
        sizeToRemove -= fileSize;
        
        final fileName = entry.key.path.split('/').last;
        final key = fileName.split('.').first;
        _cacheTimestamps.remove(key);
        
        Logger.cache('cache_cleanup_oversized', {'key': key, 'size': fileSize});
      }
    } catch (e) {
      Logger.error('Failed to cleanup oversized cache', 'CacheManager', e);
    }
  }

  /// الحصول على معلومات التخزين المؤقت
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final size = await getSize();
      final fileCount = await getFileCount();
      
      return {
        'size_bytes': size,
        'size_mb': (size / (1024 * 1024)).toStringAsFixed(2),
        'file_count': fileCount,
        'max_size_mb': (_maxCacheSize / (1024 * 1024)).toStringAsFixed(2),
        'expiration_days': _cacheExpiration.inDays,
      };
    } catch (e) {
      Logger.error('Failed to get cache info', 'CacheManager', e);
      return {};
    }
  }

  /// تحسين التخزين المؤقت
  Future<void> optimize() async {
    try {
      await _cleanupExpiredCache();
      await _cleanupOversizedCache();
      Logger.cache('cache_optimized');
    } catch (e) {
      Logger.error('Failed to optimize cache', 'CacheManager', e);
    }
  }
}