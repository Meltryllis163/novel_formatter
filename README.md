# novel_formatter

`novel_formatter`是一个用于小说格式化的Dart包。

## 小说结构说明

本程序将小说划分为以下几种[NovelElement](./lib/src/novel.dart)：

| NovelElement | 说明                                   |
|--------------|--------------------------------------|
| BlankLine    | 空行。<br />空行格式化时会被跳过。                 |
| Brief        | 简介文本行。<br />在第一卷第一章之前的文本行会被认为是简介文本行。 |
| Volume       | 卷文本行。                                |
| Chapter      | 章节文本行。                               |
| Paragraph    | 段落文本行。<br />不属于以上几种的文本行均属于章节。        |

**样例：**

```
《万相之王》 //Brief
作者：天蚕土豆 //Brief
第一卷 卷名 //Volume
第一章 我有三个相宫 //Chapter
　　大夏国，天蜀郡。 //Paragraph
　　六月的南风城，骄阳似火，炙烤大地。 //Paragraph
　　南风中等学府。 //Paragraph
　　宽敞明亮的训练场。 //Paragraph
```

## 导入依赖

```yaml
dependencies:
  novel_formatter:
    git:
      url: https://github.com/Meltryllis163/novel_formatter.git
```

## 调用

### 代码示例

```dart
void format() async {
  // 导入文件的配置项
  ImportOptions importOptions = ImportOptions(
    FileInput(File(r'ImportFilePath'), utf8),
    hasBrief: true,
    volumeImportOptions: TitleImportOptions(regexes: []),
    chapterImportOptions: TitleImportOptions(regexes: [RegExp(r'RegExpHere')]),
  );

  // 导出文件的配置项
  ExportOptions exportOptions = ExportOptions(
    FileOutput(File(r'ExportFilePath')),
    chapterTemplate: TitleTemplate(
      // 占位符详见[TitleTemplate]类。
      '第${TitleTemplate.num}章 ${TitleTemplate.name}',
    ),
    paragraphIndentation: Indentation(2, '\u3000'),
    blankLineCount: 1,
  );

  FormatProcessor processor = FormatProcessor(importOptions, exportOptions);
  await processor.format();
}
```

## 配置项说明

### ImportOptions

`ImportOptions` 是小说导入的总配置项。

| 配置项                  | 说明                                                                         | 变量类型                                      | 默认值   |
|----------------------|----------------------------------------------------------------------------|-------------------------------------------|-------|
| input                | 用于文本的读取。                                                                   | [FileInput](#FileInput)                   | 必选    |
| volumeImportOptions  | 小说「卷」的导入配置项。                                                               | [TitleImportOptions](#TitleImportOptions) | 必选    |
| chapterImportOptions | 小说「章节」的导入配配置项。                                                             | [TitleImportOptions](#TitleImportOptions) | 必选    |
| hasBrief             | 声明小说是否存在「简介」（即在第一卷、第一章之前存在的文本，例如小说名称，作者，下载地址等）。<br />该配置会影响格式化时是否解析「简介」文本。 | bool                                      | false |

#### FileInput

`FileInput`用于从文件读取文本。

| 配置项      | 说明         | 变量类型     | 默认值 |
|----------|------------|----------|-----|
| file     | 用于读入文本的文件。 | File     | 必选  |
| encoding | 文件编码。      | Encoding | 必选  |

#### TitleImportOptions

`TitleImportOptions`是「标题」相关的导入配置项。

「标题」主要是指「卷标题」和「章节标题」。

| 配置项       | 说明                                               | 变量类型           | 默认值 |
|-----------|--------------------------------------------------|----------------|-----|
| regexes   | 正则表达式列表，详见[正则表达式](#正则表达式)。                       | List\<RegExp\> | 必选  |
| maxLength | 标题的最大长度。<br />超出该长度的文本不会再尝试用正则表达式来解析，而是直接判断为非标题。 | int            | 15  |

##### 正则表达式

正则表达式主要用于「标题」文本的解析与判断。

本程序中正则表达式支持以下两个命名分组（分组名称常量存储在[`parsers.dart`](./lib/src/parsers.dart)下的
`TitleParser`类中）：

| 命名分组       | 说明                                                                                            | 存储类型    |
|------------|-----------------------------------------------------------------------------------------------|---------|
| ?\<num\>   | 该分组用于捕获标题的编号。<br />例如：「第一千零二十四章 章节名」的章节编号为「一千零二十四」。<br />该分组目前支持数字（如「1024」）以及中文数字（如「一千零二十四」）。 | int?    |
| ?\<title\> | 该分组用于捕获标题的名称。<br />例如：「第一章 陨落的天才」的章节名称为「陨落的天才」。                                               | String? |

**样例：**

正则表达式`^第(?<num>[0-9一二三四五六七八九零十百千万]+)章[\s]*(?<name>[\S]*)$`解析「第一章
陨落的天才」，解析成功，且捕获到标题编号「一」以及标题名「陨落的天才」。

### ExportOptions

`ExportOptions`是小说导出的总配置项。

| 配置项                  | 说明                      | 变量类型                                | 默认值  |
|----------------------|-------------------------|-------------------------------------|------|
| output               | 用于文本的导出。                | [FileOutput](#FileOutput)           | 必选   |
| volumeTemplate       | 「卷」导出模板，详见右侧变量类型介绍。     | [TitleTemplate](#TitleTemplate)     | null |
| chapterTemplate      | 「章节」导出模板，详见右侧变量类型介绍。    | [TitleTemplate](#TitleTemplate)     | null |
| briefIndentation     | 「简介」缩进格式配置项，详见右侧变量类型介绍。 | [Indentation](#Indentation)         | null |
| volumeIndentation    | 「卷」缩进格式配置项，详见右侧变量类型介绍。  | [Indentation](#Indentation)         | null |
| chapterIndentation   | 「章节」缩进格式配置项，详见右侧变量类型介绍。 | [Indentation](#Indentation)         | null |
| paragraphIndentation | 「段落」缩进格式配置项，详见右侧变量类型介绍。 | [Indentation](#Indentation)         | null |
| blankLineCount       | 空行数量，指文本行之间空几行。         | int                                 | 0    |
| replacements         | 导出时文本替换配置，详见右侧变量类型。     | List\<[Replacement](#Replacement)\> | []   |

#### FileOutput

`FileOutput`用于将格式化完成的文本导出至文件。

| 配置项  | 说明         | 变量类型 | 默认值 |
|------|------------|------|-----|
| file | 用于导出文本的文件。 | File | 必选  |

#### TitleTemplate

标题模板，主要用于导出标题文本时的格式化。

标题模板具有以下三种占位符：

| 占位符    | 说明      |
|--------|---------|
| {num}  | 数字编号。   |
| {cnum} | 中文数字编号。 |
| {name} | 标题名称    |

**样例：**

`第{num}章-{name}`导出时将被格式化为「第1024章-章节名」。

#### Indentation

`Indentation`用于规定文本的缩进格式。

| 配置项   | 说明      | 变量类型   | 默认值 |
|-------|---------|--------|-----|
| chars | 缩进字符。   | String | 必选  |
| count | 缩进字符数量。 | int    | 必选  |

**样例：**

`Indetation(2, '\u3000')`将会为文本开头添加两个`\u3000`（中文空格）作为缩进。

#### Replacement

`Replacement`用于文本导出时的批量替换。

| 配置项              | 说明                                         | 变量类型   | 默认值  |
|------------------|--------------------------------------------|--------|------|
| isRegExp         | 是否使用正则表达式，启用后`from`字段字符串将会被生成为正则表达式。       | bool   | 必选   |
| from             | 原文本，即需要被替换的文本，支持正则表达式（需`isRegExp = true`）。 | String | 必选   |
| to               | 目标文本，即替换后的文本。                              | String | 必选   |
| applyToBrief     | 替换规则是否对「简介」生效。                             | bool   | true |
| applyToVolume    | 替换规则是否对「卷」生效。                              | bool   | true |
| applyToChapter   | 替换规则是否对「章节」生效。                             | bool   | true |
| applyToParagraph | 替换规则是否对「段落」生效。                             | bool   | true |

## 自定义输入输出

本程序的输出输出继承自`AbstractInput`和`AbstractOutput`两个抽象类。

### AbstractInput

| 方法                                                    | 说明                                                     |
|-------------------------------------------------------|--------------------------------------------------------|
| traverse(void Function(String text) outputFormatted)) | 逐行读取小说文本，传入`outputFormatted`进行格式化与输出。该方法中抛出的异常将被本程序捕获。 |
| initialize                                            | 初始化，在`traverse`方法前执行，用于输入资源的初始化。该方法中抛出的异常将被本程序捕获。      |
| destroy                                               | 格式化结束后销毁资源。                                            |

### AbstractOutput

| 方法                  | 说明                                              |
|---------------------|-------------------------------------------------|
| output(String text) | 逐行输出文本至指定位置。                                    |
| initialize          | 初始化，在`output`方法前执行，用于输出资源的初始化。该方法中抛出的异常将被本程序捕获。 |
| destroy             | 格式化结束后销毁资源。                                     |

## 更新日志

详见[CHANGELOG.md](./CHANGELOG.md)

## TODO

- [ ] 重新分段功能，保证段落以「.」，「。」等表示结束的符号结尾。
