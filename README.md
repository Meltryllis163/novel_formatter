# novel_formatter

`novel_formatter`是一个用于小说格式化的Dart工具。

## 安装

```yaml
dependencies:
  novel_formatter:
    git:
      url: https://github.com/Meltryllis163/novel_formatter.git
```

## 调用

```dart
void format() async {
  // 导入文件的配置项
  ImportOptions importOptions = ImportOptions(
    'SourceFilePath.txt',
    volumeImportOptions: TitleImportOptions(regexes: []),
    chapterImportOptions: TitleImportOptions(
      regexes: [
        RegExp('Chapter Regex Here'),
      ],
    ),
  );

  // 导出文件的配置项
  ExportOptions exportOptions = ExportOptions(
      'ExportFilePath.txt',
      chapterTemplate: TitleTemplate(
        // 占位符详见[TitleTemplate]类。
        '第${TitleTemplate.num}章 ${TitleTemplate.name}',
      ),
      paragraphIndentation: Indentation(2, '\u3000'),
      replcements: [Replacement(true, r'正则表达式', '替换字符串')]
  );

  FormatProcessor processor = FormatProcessor(importOptions, exportOptions);
  await processor.format();
}
```

