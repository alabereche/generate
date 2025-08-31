import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _model = 'google/gemini-2.5-flash-image-preview:free';
  
  late final Dio _dio;
  
  OpenRouterService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://ai-vision-chat.app',
        'X-Title': 'AI Vision Chat',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }
  
  /// تحليل الصورة باستخدام Gemini API
  Future<String> analyzeImage(File imageFile) async {
    try {
      // تحويل الصورة إلى base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'قم بتحليل هذه الصورة ووصف محتواها بالتفصيل باللغة العربية. اذكر العناصر الموجودة في الصورة والألوان والتفاصيل المهمة.'
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      });
      
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content.toString();
      } else {
        throw Exception('فشل في تحليل الصورة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في تحليل الصورة: $e');
    }
  }
  
  /// توليد صورة باستخدام Gemini API
  Future<String> generateImage(String prompt) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'قم بتوليد صورة بناءً على هذا الوصف: $prompt. أرسل الصورة كـ base64.'
              }
            ]
          }
        ],
        'max_tokens': 1000,
        'temperature': 0.8,
      });
      
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        
        // البحث عن URL الصورة في الرد
        final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(content);
        if (urlMatch != null) {
          return urlMatch.group(0)!;
        }
        
        // البحث عن base64 في الرد
        final base64Match = RegExp(r'data:image/[^;]+;base64,([^"\s]+)').firstMatch(content);
        if (base64Match != null) {
          return base64Match.group(0)!;
        }
        
        throw Exception('لم يتم العثور على صورة في الرد');
      } else {
        throw Exception('فشل في توليد الصورة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في توليد الصورة: $e');
    }
  }
  
  /// الدردشة مع الذكاء الاصطناعي
  Future<String> chatWithAI(String message, {List<Map<String, dynamic>>? conversationHistory}) async {
    try {
      final messages = <Map<String, dynamic>>[];
      
      // إضافة تاريخ المحادثة إذا كان موجوداً
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // إضافة الرسالة الحالية
      messages.add({
        'role': 'user',
        'content': message,
      });
      
      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': messages,
        'max_tokens': 1000,
        'temperature': 0.7,
      });
      
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content.toString();
      } else {
        throw Exception('فشل في الحصول على رد: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الدردشة: $e');
    }
  }
  
  /// حفظ الصورة من URL أو base64
  Future<File> saveImageFromUrl(String imageUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'generated_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      
      if (imageUrl.startsWith('data:image/')) {
        // الصورة في شكل base64
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        await file.writeAsBytes(bytes);
      } else {
        // الصورة من URL
        final response = await _dio.get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(response.data);
      }
      
      return file;
    } catch (e) {
      throw Exception('خطأ في حفظ الصورة: $e');
    }
  }
  
  /// تحويل base64 إلى Uint8List
  Uint8List base64ToBytes(String base64String) {
    final base64Data = base64String.split(',')[1];
    return base64Decode(base64Data);
  }
}