import 'utils.dart';

/// 小说中的各个部分。
/// 包括标题[Title]、正文段落[Paragraph]以及空行[BlankLine]。
abstract class NovelElement {
  /// 当前部分对应的文本。
  final String text;

  const NovelElement(this.text);
}

/// 小说空文本行。
class BlankLine extends NovelElement {
  const BlankLine() : super(StrUtil.empty);
}

/// 小说标题，例如卷标题和章节标题。
class Title extends NovelElement {
  /// 标题编号。
  final int? number;

  /// 标题名称。
  final String? name;

  const Title(super.text, this.number, this.name);
}

/// 小说正文段落。
///
/// 不属于其他类型的[NovelElement]的文本会被认为是正文段落。
/// 由于本程序是逐行读取，因此在无特殊处理的情况下，通常将一行看作一段。
class Paragraph extends NovelElement {
  const Paragraph(super.text);

  /// 判断段落是否完整。
  /// 段落完整即段落文本以[Punctuation.terminalPunctuations]中的标点符号结尾。
  bool isComplete() {
    String lastChr = text[text.length - 1];
    return Punctuation.terminalPunctuations.contains(lastChr);
  }
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
