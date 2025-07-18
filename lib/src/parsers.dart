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
