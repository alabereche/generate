import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

/// امتدادات للنصوص
extension StringExtensions on String {
  /// تحويل النص إلى عنوان
  String get toTitleCase {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// تقصير النص
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// التحقق من أن النص فارغ أو يحتوي على مسافات فقط
  bool get isNullOrEmpty => trim().isEmpty;

  /// التحقق من أن النص ليس فارغاً
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// إزالة الأحرف الخاصة
  String get sanitized => replaceAll(RegExp(r'[^\w\s-]'), '');

  /// تحويل النص إلى base64
  String get toBase64 => base64Encode(utf8.encode(this));

  /// التحقق من أن النص بريد إلكتروني صحيح
  bool get isEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// التحقق من أن النص رقم هاتف صحيح
  bool get isPhone {
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{8,15}$');
    return phoneRegex.hasMatch(this);
  }

  /// التحقق من أن النص URL صحيح
  bool get isUrl {
    try {
      Uri.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على امتداد الملف
  String get fileExtension {
    final parts = split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// الحصول على اسم الملف بدون الامتداد
  String get fileNameWithoutExtension {
    final parts = split('.');
    return parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : this;
  }

  /// تحويل النص إلى رقم
  int? get toInt {
    try {
      return int.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// تحويل النص إلى رقم عشري
  double? get toDouble {
    try {
      return double.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// تحويل النص إلى تاريخ
  DateTime? get toDateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// عكس النص
  String get reversed => split('').reversed.join();

  /// حساب عدد الكلمات
  int get wordCount {
    if (trim().isEmpty) return 0;
    return trim().split(RegExp(r'\s+')).length;
  }

  /// الحصول على الكلمات الأولى
  String getFirstWords(int count) {
    final words = trim().split(RegExp(r'\s+'));
    if (words.length <= count) return this;
    return words.take(count).join(' ');
  }

  /// إزالة الأحرف المكررة
  String get removeDuplicates {
    final seen = <String>{};
    return split('').where((char) => seen.add(char)).join();
  }

  /// تحويل النص إلى camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    final words = toLowerCase().split(RegExp(r'[\s_-]+'));
    return words[0] + words.skip(1).map((word) => word.toTitleCase).join();
  }

  /// تحويل النص إلى snake_case
  String get toSnakeCase {
    return toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  }

  /// تحويل النص إلى kebab-case
  String get toKebabCase {
    return toLowerCase().replaceAll(RegExp(r'[\s_]+'), '-');
  }
}

/// امتدادات للأرقام
extension NumberExtensions on num {
  /// تنسيق الرقم مع فواصل
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// تنسيق الرقم كنسبة مئوية
  String get toPercentage => '${(this * 100).toStringAsFixed(1)}%';

  /// تنسيق الرقم كعملة
  String get toCurrency => '\$${toStringAsFixed(2)}';

  /// تنسيق الرقم كعملة عربية
  String get toArabicCurrency => '${toStringAsFixed(2)} ريال';

  /// تنسيق الرقم كحجم ملف
  String get toFileSize {
    if (this < 1024) return '${toStringAsFixed(0)} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// تنسيق الرقم كوقت
  String get toTime {
    final hours = (this / 3600).floor();
    final minutes = ((this % 3600) / 60).floor();
    final seconds = (this % 60).floor();
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// تنسيق الرقم كمسافة
  String get toDistance {
    if (this < 1000) return '${toStringAsFixed(0)} م';
    return '${(this / 1000).toStringAsFixed(1)} كم';
  }

  /// تنسيق الرقم كوزن
  String get toWeight {
    if (this < 1000) return '${toStringAsFixed(0)} جم';
    return '${(this / 1000).toStringAsFixed(1)} كجم';
  }

  /// تنسيق الرقم كدرجة حرارة
  String get toTemperature => '${toStringAsFixed(1)}°C';

  /// تنسيق الرقم كضغط
  String get toPressure => '${toStringAsFixed(0)} بار';

  /// تنسيق الرقم كسرعة
  String get toSpeed => '${toStringAsFixed(1)} كم/س';
}

/// امتدادات للتواريخ
extension DateTimeExtensions on DateTime {
  /// التحقق من أن التاريخ اليوم
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// التحقق من أن التاريخ أمس
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// التحقق من أن التاريخ غداً
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// التحقق من أن التاريخ في هذا الأسبوع
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) && isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// التحقق من أن التاريخ في هذا الشهر
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// التحقق من أن التاريخ في هذا العام
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// الحصول على اسم اليوم بالعربية
  String get arabicDayName {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[weekday % 7];
  }

  /// الحصول على اسم الشهر بالعربية
  String get arabicMonthName {
    const months = [
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  /// تنسيق التاريخ بالعربية
  String get arabicFormat {
    return '$arabicDayName ${day} $arabicMonthName $year';
  }

  /// تنسيق التاريخ المختصر
  String get shortFormat {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
  }

  /// تنسيق التاريخ والوقت
  String get dateTimeFormat {
    return '${shortFormat} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// الحصول على الوقت النسبي
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  /// الحصول على العمر
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

/// امتدادات للقوائم
extension ListExtensions<T> on List<T> {
  /// الحصول على العنصر الأول أو قيمة افتراضية
  T? get firstOrNull => isEmpty ? null : first;

  /// الحصول على العنصر الأخير أو قيمة افتراضية
  T? get lastOrNull => isEmpty ? null : last;

  /// إضافة عنصر إذا لم يكن موجوداً
  void addIfNotExists(T item) {
    if (!contains(item)) {
      add(item);
    }
  }

  /// إزالة العناصر المكررة
  List<T> get unique => toSet().toList();

  /// تقسيم القائمة إلى مجموعات
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// الحصول على عنصر عشوائي
  T? get random {
    if (isEmpty) return null;
    return this[DateTime.now().millisecondsSinceEpoch % length];
  }

  /// تبديل موقع عنصرين
  void swap(int index1, int index2) {
    if (index1 >= 0 && index1 < length && index2 >= 0 && index2 < length) {
      final temp = this[index1];
      this[index1] = this[index2];
      this[index2] = temp;
    }
  }

  /// إزالة العناصر الفارغة
  List<T> get removeNulls => where((item) => item != null).toList();

  /// الحصول على العناصر المميزة
  List<T> get distinct => toSet().toList();

  /// عكس القائمة
  List<T> get reversed => List.from(this).reversed.toList();

  /// خلط القائمة
  List<T> get shuffled => List.from(this)..shuffle();
}

/// امتدادات للخرائط
extension MapExtensions<K, V> on Map<K, V> {
  /// الحصول على قيمة أو قيمة افتراضية
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  /// إضافة عنصر إذا لم يكن موجوداً
  void putIfNotExists(K key, V value) {
    if (!containsKey(key)) {
      this[key] = value;
    }
  }

  /// إزالة العناصر الفارغة
  Map<K, V> get removeNulls {
    final result = <K, V>{};
    forEach((key, value) {
      if (value != null) {
        result[key] = value;
      }
    });
    return result;
  }

  /// عكس المفاتيح والقيم
  Map<V, K> get inverted {
    final result = <V, K>{};
    forEach((key, value) {
      result[value] = key;
    });
    return result;
  }

  /// دمج خريطة أخرى
  Map<K, V> merge(Map<K, V> other) {
    final result = Map<K, V>.from(this);
    result.addAll(other);
    return result;
  }
}

/// امتدادات للـ Widgets
extension WidgetExtensions on Widget {
  /// إضافة padding
  Widget padding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// إضافة margin
  Widget margin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  /// إضافة border
  Widget border({
    Border? border,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: border,
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }

  /// إضافة background color
  Widget backgroundColor(Color color) {
    return Container(color: color, child: this);
  }

  /// إضافة gradient background
  Widget gradientBackground(Gradient gradient) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: this,
    );
  }

  /// إضافة shadow
  Widget shadow({
    Color? color,
    double? blurRadius,
    Offset? offset,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color ?? Colors.black26,
            blurRadius: blurRadius ?? 4,
            offset: offset ?? const Offset(0, 2),
          ),
        ],
      ),
      child: this,
    );
  }

  /// إضافة corner radius
  Widget cornerRadius(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  /// إضافة opacity
  Widget opacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// إضافة scale
  Widget scale(double scale) {
    return Transform.scale(scale: scale, child: this);
  }

  /// إضافة rotation
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }

  /// إضافة translation
  Widget translate(Offset offset) {
    return Transform.translate(offset: offset, child: this);
  }

  /// إضافة gesture detector
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// إضافة long press
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(onLongPress: onLongPress, child: this);
  }

  /// إضافة double tap
  Widget onDoubleTap(VoidCallback onDoubleTap) {
    return GestureDetector(onDoubleTap: onDoubleTap, child: this);
  }

  /// إضافة visibility
  Widget visible(bool visible) {
    return Visibility(visible: visible, child: this);
  }

  /// إضافة expanded
  Widget get expanded => Expanded(child: this);

  /// إضافة flexible
  Widget flexible([int flex = 1]) => Flexible(flex: flex, child: this);

  /// إضافة sized box
  Widget sizedBox({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  /// إضافة center
  Widget get centered => Center(child: this);

  /// إضافة align
  Widget align(Alignment alignment) {
    return Align(alignment: alignment, child: this);
  }

  /// إضافة positioned
  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: this,
    );
  }
}