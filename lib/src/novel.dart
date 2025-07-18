import 'utils.dart';

enum NovelElementType {
  /// 简介。
  brief,

  /// 卷。
  volume,

  /// 章节。
  chapter,

  /// 段落。
  paragraph,

  /// 空行。
  blankLine,
}

/// 小说元素是指小说中的各个部分。
/// 包括简介[Brief]、卷「Volume」、章节「Chapter」正文段落[Paragraph]以及空行[BlankLine]。
/// 由于本程序采取逐行读取的方式，因此所有小说元素均代表元素行。
abstract class NovelElement {
  /// 小说元素类型。
  NovelElementType get type;

  /// 当前部分对应的文本。
  final String text;

  const NovelElement(this.text);
}

/// 空行。
class BlankLine extends NovelElement {
  @override
  NovelElementType get type => NovelElementType.blankLine;

  const BlankLine() : super(StrUtil.empty);
}

/// 简介。
/// 在第一卷第一章开始之前，可能会存在一些小说元数据。
/// 比如小说名、作者、下载地址、简介等等内容，这些内容统一定义为小说简介。
class Brief extends NovelElement {
  @override
  NovelElementType get type => NovelElementType.brief;

  Brief(super.text);
}

/// 小说标题，例如「卷」标题和「章节」标题。
abstract class Title extends NovelElement {
  /// 标题编号。
  final int? number;

  /// 标题名称。
  final String? name;

  const Title(super.text, this.number, this.name);
}

/// 卷。
class Volume extends Title {
  Volume(super.text, super.number, super.name);

  @override
  NovelElementType get type => NovelElementType.volume;
}

/// 章节。
class Chapter extends Title {
  Chapter(super.text, super.number, super.name);

  @override
  NovelElementType get type => NovelElementType.chapter;
}

/// 正文段落。
///
/// 不属于其他类型的[NovelElement]的文本都会被认为是正文段落。
class Paragraph extends NovelElement {
  @override
  NovelElementType get type => NovelElementType.paragraph;

  const Paragraph(super.text);
}
