import 'dart:io';

import 'package:chinese_number/chinese_number.dart';

class StrUtil {
  /// 空字符串。
  static const String empty = '';

  /// 返回字符串的最后一个字符。
  /// 不存在则返回[empty]。
  static String getLastCharacter(String? str) {
    if (str == null || str.isEmpty) {
      return empty;
    }
    return str[str.length - 1];
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
    file.writeAsStringSync(StrUtil.empty);
    return true;
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
