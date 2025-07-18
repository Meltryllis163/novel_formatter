import '../novel_formatter.dart';
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

class BriefParser extends AbstractParser {
  final ImportOptions _options;
  final FormatResult _result;

  BriefParser(this._options, this._result);

  @override
  Brief? tryParse(String input) {
    if (_options.hasBrief &&
        _result.volumeCount == 0 &&
        _result.chapterCount == 0) {
      return Brief(input);
    }
    return null;
  }
}

abstract class TitleParser<T extends Title> extends AbstractParser {
  /// 正则表达式命名分组：标题编号。
  static const String numGroup = 'num';

  /// 正则表达式命名分组：标题名。
  static const String nameGroup = 'name';

  final TitleImportOptions _options;

  TitleParser(this._options);

  @override
  T? tryParse(String input) {
    if (input.length > _options.maxLength) {
      return null;
    }
    for (RegExp regex in _options.regexes) {
      RegExpMatch? match = regex.firstMatch(input);
      if (match != null) {
        String? numGroupStr = match.groupNames.contains(numGroup)
            ? match.namedGroup(numGroup)
            : null;
        String? nameGroupStr = match.groupNames.contains(nameGroup)
            ? match.namedGroup(nameGroup)
            : null;
        return _create(
          input,
          NumberUtil.tryParse(numGroupStr)?.toInt(),
          nameGroupStr,
        );
      }
    }
    return null;
  }

  T _create(String text, int? number, String? name);
}

class VolumeParser extends TitleParser<Volume> {
  VolumeParser(super.options);

  @override
  Volume _create(String text, int? number, String? name) {
    return Volume(text, number, name);
  }
}

class ChapterParser extends TitleParser<Chapter> {
  ChapterParser(super.options);

  @override
  Chapter _create(String text, int? number, String? name) {
    return Chapter(text, number, name);
  }
}

class ParagraphParser extends AbstractParser {
  final ParagraphImportOptions _options;
  final StringBuffer _buffer = StringBuffer();

  ParagraphParser(this._options);

  /// 判断文本是否为完整章节文本，即是否以[Punctuation.terminalPunctuations]结尾。
  bool _isComplete(String text) {
    String curText = (_buffer..write(text)).toString();
    if (curText.length > _options.maxLength) {
      return true;
    }
    String lastChar = StrUtil.getLastCharacter(curText);
    return Punctuation.terminalPunctuations.contains(lastChar);
  }

  String getBufferString() {
    return _buffer.toString();
  }

  @override
  Paragraph? tryParse(String input) {
    if (!_options.resegment) {
      return Paragraph(input);
    }
    if (_isComplete(input)) {
      String paragraphText = _buffer.toString();
      _buffer.clear();
      return Paragraph(paragraphText);
    } else {
      return null;
    }
  }
}

/// 自用的标题正则解析字符串。
class TitleRegExp {
  // 卷正则 ==============================================
  /// 第一卷 卷名；
  /// 第1卷 卷名。
  static final RegExp v1 = RegExp(
    '^第(?<${TitleParser.numGroup}>[0-9一二三四五六七八九零十百千万]+)卷[\\s]*(?<${TitleParser.nameGroup}>[\\S]*)\$',
  );

  // 章节正则 ==============================================
  /// 第一章 章节名；
  /// 第1章 章节名。
  static final RegExp c1 = RegExp(
    '^第(?<${TitleParser.numGroup}>[0-9一二三四五六七八九零十百千万]+)章[\\s]*(?<${TitleParser.nameGroup}>[\\S]*)\$',
  );
}

/// 标点符号工具类，包含常用的中文和英文标点符号。
class Punctuation {
  // 英文标点符号 ==============================================

  /// 英文逗号。
  static const String enComma = ',';

  /// 英文句号。
  static const String enPeriod = '.';

  /// 英文问号。
  static const String enQuestionMark = '?';

  /// 英文感叹号。
  static const String enExclamationMark = '!';

  /// 英文冒号。
  static const String enColon = ':';

  /// 英文分号。
  static const String enSemicolon = ';';

  /// 英文单引号。
  static const String enSingleQuote = '\'';

  /// 英文双引号。
  static const String enDoubleQuote = '"';

  /// 英文反引号。
  static const String enBacktick = '`';

  /// 英文波浪号。
  static const String enTilde = '~';

  /// 英文下划线。
  static const String enUnderscore = '_';

  /// 英文加号。
  static const String enPlus = '+';

  /// 英文等号。
  static const String enEqual = '=';

  /// 英文星号。
  static const String enAsterisk = '*';

  /// 英文and符号。
  static const String enAmpersand = '&';

  /// 英文at符号。
  static const String enAt = '@';

  /// 英文井号。
  static const String enHash = '#';

  /// 英文美元符号。
  static const String enDollar = '\$';

  /// 英文百分号。
  static const String enPercent = '%';

  /// 英文脱字符。
  static const String enCaret = '^';

  /// 英文斜杠。
  static const String enSlash = '/';

  /// 英文反斜杠。
  static const String enBackslash = '\\';

  /// 英文竖线。
  static const String enPipe = '|';

  /// 英文左圆括号。
  static const String enLeftParenthesis = '(';

  /// 英文右圆括号。
  static const String enRightParenthesis = ')';

  /// 英文左方括号。
  static const String enLeftBracket = '[';

  /// 英文右方括号。
  static const String enRightBracket = ']';

  /// 英文左花括号。
  static const String enLeftBrace = '{';

  /// 英文右花括号。
  static const String enRightBrace = '}';

  /// 英文小于号。
  static const String enLessThan = '<';

  /// 英文大于号。
  static const String enGreaterThan = '>';

  // 中文标点符号 ==============================================

  /// 中文逗号。
  static const String zhComma = '，';

  /// 中文句号。
  static const String zhPeriod = '。';

  /// 中文问号。
  static const String zhQuestionMark = '？';

  /// 中文感叹号。
  static const String zhExclamationMark = '！';

  /// 中文冒号。
  static const String zhColon = '：';

  /// 中文分号。
  static const String zhSemicolon = '；';

  /// 中文左单引号。
  static const String zhLeftSingleQuote = '‘';

  /// 中文右单引号。
  static const String zhRightSingleQuote = '’';

  /// 中文左双引号。
  static const String zhLeftDoubleQuote = '“';

  /// 中文右双引号。
  static const String zhRightDoubleQuote = '”';

  /// 中文左直角引号。
  static const String zhLeftCornerBracket = '「';

  /// 中文右直角引号。
  static const String zhRightCornerBracket = '」';

  /// 中文间隔号。
  static const String zhMiddleDot = '·';

  /// 中文省略号。
  static const String zhEllipsis = '…';

  /// 中文破折号。
  static const String zhDash = '—';

  /// 中文波浪号。
  static const String zhWaveDash = '～';

  /// 中文左书名号。
  static const String zhLeftBookTitleMark = '《';

  /// 中文右书名号。
  static const String zhRightBookTitleMark = '》';

  /// 中文左单书名号。
  static const String zhLeftSingleBookTitleMark = '〈';

  /// 中文右单书名号。
  static const String zhRightSingleBookTitleMark = '〉';

  /// 中文左实方括号。
  static const String zhLeftBracket = '【';

  /// 中文右实方括号。
  static const String zhRightBracket = '】';

  /// 中文左空方括号。
  static const String zhLeftWhiteBracket = '〔';

  /// 中文右空方括号。
  static const String zhRightWhiteBracket = '〕';

  /// 表示句子结束的标点符号集合。
  static const List<String> terminalPunctuations = [
    enPeriod,
    enQuestionMark,
    enExclamationMark,
    enDoubleQuote,
    zhPeriod,
    zhQuestionMark,
    zhExclamationMark,
    zhRightDoubleQuote,
    zhRightCornerBracket,
    zhEllipsis,
  ];
}
