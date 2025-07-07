import 'novel.dart';
import 'options.dart';
import 'utils.dart';

abstract class AbstractParser {
  NovelElement? tryParse(String input);
}

class BlankLineParser extends AbstractParser {
  @override
  BlankLine? tryParse(String? input) {
    return (input ?? StrUtil.empty).isEmpty ? BlankLine() : null;
  }
}

class TitleParser extends AbstractParser {
  /// 正则表达式命名分组：标题编号。
  static const String numGroup = 'num';

  /// 正则表达式命名分组：标题名。
  static const String nameGroup = 'name';

  TitleImportOptions options;

  TitleParser(this.options);

  @override
  Title? tryParse(String input) {
    if (input.length > options.maxLength) {
      return null;
    }
    for (RegExp regex in options.regexes) {
      RegExpMatch? match = regex.firstMatch(input);
      if (match != null) {
        return Title(
          input,
          NumberUtil.tryParse(match.namedGroup(numGroup))?.toInt() ?? 0,
          match.namedGroup(nameGroup),
        );
      }
    }
    return null;
  }
}

/// 自用的标题正则解析字符串。
class TitleRegExp {
  // 卷正则 ==============================================
  /// 第一卷 卷名；
  /// 第1卷 卷名。
  static const String volume1 =
      '^第(?<${TitleParser.numGroup}>[0-9一二三四五六七八九零十百千万]+)卷[\\s]*(?<${TitleParser.nameGroup}>[\\S]*)\$';

  // 章节正则 ==============================================
  /// 第一章 章节名；
  /// 第1章 章节名。
  static const String chapter1 =
      '^第(?<${TitleParser.numGroup}>[0-9一二三四五六七八九零十百千万]+)章[\\s]*(?<${TitleParser.nameGroup}>[\\S]*)\$';
}
