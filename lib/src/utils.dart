import 'dart:io';

import 'package:chinese_number/chinese_number.dart';

class StrUtil {
  /// 空字符串。
  static const String empty = '';

  /// 重复[str]字符串[count]次。
  ///
  /// 如果字符串为[null]或者[isEmpty]，则返回[empty]。
  /// 如果[count]为0，则返回原字符串。
  static String repeat(String? str, int count) {
    if (str == null || str.isEmpty) {
      return empty;
    }
    if (count <= 0) {
      return str;
    }
    StringBuffer buffer = StringBuffer(str);
    for (int i = 0; i < count; i++) {
      buffer.write(str);
    }
    return buffer.toString();
  }
}

class NumberUtil {
  /// [int.tryParse] 的增强版，会尝试解析中文数字字符串。
  static num? tryParse(String? str) {
    if (str == null) {
      return null;
    }
    int? num = int.tryParse(str);
    if (num != null) {
      return num;
    }
    return ChineseNumber.tryParse(str);
  }
}

class FileUtil {
  /// 清空文件内容。
  static bool clear(File? file) {
    if (file == null || !file.existsSync()) {
      return false;
    }
    try {
      file.writeAsStringSync(StrUtil.empty);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 如果文件不存在，则创建文件。
  static bool createFile(File? file) {
    if (file == null) {
      return false;
    }
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return true;
  }
}
