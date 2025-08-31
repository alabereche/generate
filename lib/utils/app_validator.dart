import 'package:flutter/material.dart';
import 'logger.dart';

class AppValidator {
  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    if (value.length > 50) {
      return 'كلمة المرور يجب أن تكون أقل من 50 حرف';
    }
    
    return null;
  }

  /// التحقق من صحة تأكيد كلمة المرور
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  /// التحقق من صحة الاسم
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    
    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    
    if (value.length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'الاسم يجب أن يحتوي على أحرف فقط';
    }
    
    return null;
  }

  /// التحقق من صحة رقم الهاتف
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة النص المطلوب
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    return null;
  }

  /// التحقق من صحة النص مع الحد الأدنى
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
    }
    
    return null;
  }

  /// التحقق من صحة النص مع الحد الأقصى
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName يجب أن يكون أقل من $maxLength حرف';
    }
    
    return null;
  }

  /// التحقق من صحة النص مع الحد الأدنى والأقصى
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName يجب أن يكون أقل من $maxLength حرف';
    }
    
    return null;
  }

  /// التحقق من صحة الرقم
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    final numberRegex = RegExp(r'^[0-9]+$');
    if (!numberRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال رقم صحيح';
    }
    
    return null;
  }

  /// التحقق من صحة الرقم العشري
  static String? validateDecimal(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    final decimalRegex = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    if (!decimalRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال رقم صحيح أو عشري';
    }
    
    return null;
  }

  /// التحقق من صحة URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الرابط';
    }
    
    try {
      Uri.parse(value.trim());
      return null;
    } catch (e) {
      return 'يرجى إدخال رابط صحيح';
    }
  }

  /// التحقق من صحة التاريخ
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال التاريخ';
    }
    
    try {
      DateTime.parse(value.trim());
      return null;
    } catch (e) {
      return 'يرجى إدخال تاريخ صحيح';
    }
  }

  /// التحقق من صحة التاريخ مع الحد الأدنى
  static String? validateMinDate(String? value, DateTime minDate) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال التاريخ';
    }
    
    try {
      final date = DateTime.parse(value.trim());
      if (date.isBefore(minDate)) {
        return 'التاريخ يجب أن يكون بعد ${minDate.toString().split(' ')[0]}';
      }
      return null;
    } catch (e) {
      return 'يرجى إدخال تاريخ صحيح';
    }
  }

  /// التحقق من صحة التاريخ مع الحد الأقصى
  static String? validateMaxDate(String? value, DateTime maxDate) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال التاريخ';
    }
    
    try {
      final date = DateTime.parse(value.trim());
      if (date.isAfter(maxDate)) {
        return 'التاريخ يجب أن يكون قبل ${maxDate.toString().split(' ')[0]}';
      }
      return null;
    } catch (e) {
      return 'يرجى إدخال تاريخ صحيح';
    }
  }

  /// التحقق من صحة التاريخ مع النطاق
  static String? validateDateRange(String? value, DateTime minDate, DateTime maxDate) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال التاريخ';
    }
    
    try {
      final date = DateTime.parse(value.trim());
      if (date.isBefore(minDate)) {
        return 'التاريخ يجب أن يكون بعد ${minDate.toString().split(' ')[0]}';
      }
      if (date.isAfter(maxDate)) {
        return 'التاريخ يجب أن يكون قبل ${maxDate.toString().split(' ')[0]}';
      }
      return null;
    } catch (e) {
      return 'يرجى إدخال تاريخ صحيح';
    }
  }

  /// التحقق من صحة الملف
  static String? validateFile(String? value, List<String> allowedExtensions) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى اختيار ملف';
    }
    
    final extension = value.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'نوع الملف غير مدعوم. الأنواع المدعومة: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }

  /// التحقق من صحة حجم الملف
  static String? validateFileSize(int fileSize, int maxSizeInBytes) {
    if (fileSize > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'حجم الملف يجب أن يكون أقل من $maxSizeMB MB';
    }
    
    return null;
  }

  /// التحقق من صحة الصورة
  static String? validateImage(String? value) {
    return validateFile(value, ['jpg', 'jpeg', 'png', 'gif', 'webp']);
  }

  /// التحقق من صحة الفيديو
  static String? validateVideo(String? value) {
    return validateFile(value, ['mp4', 'avi', 'mov', 'wmv', 'flv']);
  }

  /// التحقق من صحة المستند
  static String? validateDocument(String? value) {
    return validateFile(value, ['pdf', 'doc', 'docx', 'txt', 'rtf']);
  }

  /// التحقق من صحة الكود البريدي
  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الكود البريدي';
    }
    
    final postalCodeRegex = RegExp(r'^[0-9]{5}$');
    if (!postalCodeRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال كود بريدي صحيح (5 أرقام)';
    }
    
    return null;
  }

  /// التحقق من صحة رقم الهوية
  static String? validateIdNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الهوية';
    }
    
    final idRegex = RegExp(r'^[0-9]{10}$');
    if (!idRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال رقم هوية صحيح (10 أرقام)';
    }
    
    return null;
  }

  /// التحقق من صحة كلمة المرور القوية
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }
    
    return null;
  }

  /// التحقق من صحة النص العربي
  static String? validateArabicText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    if (!arabicRegex.hasMatch(value.trim())) {
      return '$fieldName يجب أن يكون باللغة العربية';
    }
    
    return null;
  }

  /// التحقق من صحة النص الإنجليزي
  static String? validateEnglishText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    
    final englishRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!englishRegex.hasMatch(value.trim())) {
      return '$fieldName يجب أن يكون باللغة الإنجليزية';
    }
    
    return null;
  }
}