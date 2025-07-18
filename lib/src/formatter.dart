import 'dart:io';

import '../novel_formatter.dart';
import 'logger.dart';

/// 小说格式化处理器。
///
/// 此类负责小说的整个格式化流程，包括：读取、格式化、导出。
class FormatProcessor {
  /// 小说导入配置项。
  final ImportOptions _importOptions;

  /// 小说导出配置项。
  final ExportOptions _exportOptions;

  FormatProcessor(this._importOptions, this._exportOptions);

  late final AbstractInput _input;
  late final AbstractOutput _output;

  late final BlankLineParser _blankLineParser;
  late final VolumeParser _volumeParser;
  late final ChapterParser _chapterParser;

  late final BriefFormatter _briefFormatter;
  late final VolumeFormatter _volumeFormatter;
  late final ChapterFormatter _chapterFormatter;
  late final BriefParser _briefParser;
  late final ParagraphFormatter _paragraphFormatter;

  late final FormatResult _formatResult;

  /// 初始化解析器和格式化器。
  void initialize() {
    // 初始化输入输出流。
    _input = _importOptions.input;
    _output = _exportOptions.output;
    // 格式化结果初始化。
    _formatResult = FormatResult();
    // 解析器初始化。
    initializeParsers();
    // 格式器初始化。
    initializeFormatters();
  }

  /// 初始化解析器。
  void initializeParsers() {
    _blankLineParser = BlankLineParser();
    _volumeParser = VolumeParser(_importOptions.volumeImportOptions);
    _chapterParser = ChapterParser(_importOptions.chapterImportOptions);
    _briefParser = BriefParser(_importOptions, _formatResult);
  }

  /// 初始化格式化器。
  void initializeFormatters() {
    _briefFormatter = BriefFormatter(
      indentation: _exportOptions.briefIndentation,
      replacements: _exportOptions.replacements,
    );
    _volumeFormatter = VolumeFormatter.fromOptions(
      options: _exportOptions.volumeExportOptions,
      replacements: _exportOptions.replacements,
    );
    _chapterFormatter = ChapterFormatter.fromOptions(
      options: _exportOptions.chapterExportOptions,
      replacements: _exportOptions.replacements,
    );
    _paragraphFormatter = ParagraphFormatter(
      indentation: _exportOptions.paragraphIndentation,
      replacements: _exportOptions.replacements,
    );
  }

  /// 格式化小说。
  Future<FormatResult> format() async {
    initialize();
    try {
      _input.initialize();
      _output.initialize();
      Stream<String> lines = _input.stream;
      await for (String line in lines) {
        String text = line.trim();
        // 解析为NovelElement。
        NovelElement? element = _parseNovelElement(text);
        // 统计NovelElement信息。
        _countNovelElement(element);
        // 格式化NovelElement字符串并输出。
        String? outputText = _formatNovelElement(element);
        _outputFormatText(outputText);
      }
      _input.destroy();
      _output.destroy();
      logger.i('Format success.');
      return _formatResult;
    } catch (e) {
      logger.e('Format failed.', error: e);
      _formatResult.fail(e);
      return _formatResult;
    }
  }

  NovelElement? _parseNovelElement(String text) {
    return _blankLineParser.tryParse(text) ??
        _volumeParser.tryParse(text) ??
        _chapterParser.tryParse(text) ??
        _briefParser.tryParse(text) ??
        Paragraph(text);
  }

  void _countNovelElement(NovelElement? element) {
    switch (element) {
      case Volume _:
        _formatResult.volumeCount++;
      case Chapter _:
        _formatResult.chapterCount++;
      default:
        break;
    }
  }

  String? _formatNovelElement(NovelElement? element) {
    return switch (element) {
      Brief brief => _briefFormatter.format(brief),
      Volume volume => _volumeFormatter.format(volume),
      Chapter chapter => _chapterFormatter.format(chapter),
      Paragraph paragraph => _paragraphFormatter.format(paragraph),
      _ => null,
    };
  }

  void _outputFormatText(String? text) {
    if (text == null) {
      return;
    }
    final String lineTerminator = Platform.lineTerminator;
    // 输出格式化文本 + 换行符。
    _output.output(text + lineTerminator);
    // 输出空行。
    final int blankLineCount = _exportOptions.blankLineCount;
    if (blankLineCount <= 0) {
      return;
    }
    _output.output(lineTerminator * blankLineCount);
  }
}

class FormatResult {
  late bool success = true;
  Object? exception;

  void fail(Object e) {
    success = false;
    exception = e;
  }

  int volumeCount = 0;
  int chapterCount = 0;

  @override
  String toString() {
    return 'FormatResult{success: $success, exception: $exception, volumeCount: $volumeCount, chapterCount: $chapterCount}';
  }
}

abstract class AbstractNovelElementFormatter<T extends NovelElement> {
  final Indentation? indentation;
  final List<Replacement> replacements;

  AbstractNovelElementFormatter({
    this.indentation,
    this.replacements = const [],
  });

  /// 根据不同格式器的规则，各自解析[T]来获取用于后续通用格式化流程的文本。
  String _resolveText(T brief);

  /// 格式化[T]，返回格式化字符串。
  String format(T element) {
    String text = _resolveText(element);
    String replaced = _replace(text);
    return indent(replaced);
  }

  /// 判断当前格式器是否允许[replacement]替换规则。
  bool _acceptReplacement(Replacement replacement);

  /// 对[input]字符串应用[replacements]替换规则。
  String _replace(String input) {
    String replaced = input;
    for (Replacement r in replacements) {
      if (_acceptReplacement(r)) {
        replaced = r.applyTo(replaced);
      }
    }
    return replaced;
  }

  /// 对[input]字符串添加[indentation]缩进。
  /// 当[indentation]为`null`时返回原字符串。
  String indent(String input) {
    return indentation == null ? input : indentation!.applyTo(input);
  }
}

abstract class AbstractTitleFormatter
    extends AbstractNovelElementFormatter<Title> {
  /// 标题模板。
  final TitleTemplate? template;

  AbstractTitleFormatter({
    this.template,
    super.indentation,
    super.replacements,
  });

  AbstractTitleFormatter.fromOptions(
    TitleExportOptions? options,
    List<Replacement> replacements,
  ) : this(
        template: options?.template,
        indentation: options?.indentation,
        replacements: replacements,
      );

  /// 使用[template]模板解析[Title]标题。
  /// 如果[template]为`null`则直接返回标题文本。
  @override
  String _resolveText(Title brief) {
    Title title = brief;
    if (template == null) {
      return title.text;
    }
    return template!.fill(title);
  }
}

class VolumeFormatter extends AbstractTitleFormatter {
  VolumeFormatter.fromOptions({
    TitleExportOptions? options,
    List<Replacement> replacements = const [],
  }) : super.fromOptions(options, replacements);

  @override
  bool _acceptReplacement(Replacement replacement) {
    return replacement.applyToVolume;
  }
}

class ChapterFormatter extends AbstractTitleFormatter {
  ChapterFormatter.fromOptions({
    TitleExportOptions? options,
    List<Replacement> replacements = const [],
  }) : super.fromOptions(options, replacements);

  @override
  bool _acceptReplacement(Replacement replacement) {
    return replacement.applyToVolume;
  }
}

class ParagraphFormatter extends AbstractNovelElementFormatter<Paragraph> {
  ParagraphFormatter({super.indentation, super.replacements});

  @override
  bool _acceptReplacement(Replacement replacement) {
    return replacement.applyToParagraph;
  }

  @override
  String _resolveText(Paragraph brief) {
    return brief.text;
  }
}

class BriefFormatter extends AbstractNovelElementFormatter<Brief> {
  BriefFormatter({super.indentation, super.replacements});

  @override
  bool _acceptReplacement(Replacement replacement) {
    return replacement.applyToBrief;
  }

  @override
  String _resolveText(Brief brief) {
    return brief.text;
  }
}

/// 替换规则，用于小说文本的批量替换。
class Replacement {
  final String from;
  final String to;

  /// [from]是否为正则字符串。
  final bool isRegExp;

  /// 是否对简介有效。
  final bool applyToBrief;

  /// 是否对卷有效。
  final bool applyToVolume;

  /// 是否对章节有效。
  final bool applyToChapter;

  /// 是否对段落有效。
  final bool applyToParagraph;

  Replacement(
    this.isRegExp,
    this.from,
    this.to, {
    this.applyToBrief = true,
    this.applyToVolume = true,
    this.applyToChapter = true,
    this.applyToParagraph = true,
  });

  /// 将当前替换规则应用到[input]。
  String applyTo(String input) {
    return input.replaceAll(isRegExp ? RegExp(from) : from, to);
  }
}
