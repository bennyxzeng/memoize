// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Memoize';

  @override
  String get newDeck => '新建牌组';

  @override
  String get editDeck => '编辑牌组';

  @override
  String get deleteDeck => '删除牌组';

  @override
  String get deckName => '牌组名称';

  @override
  String get deckDescription => '描述（可选）';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get required => '必填';

  @override
  String get noDecks => '暂无牌组。\n点击 + 创建新牌组。';

  @override
  String get deleteDeckTitle => '删除牌组？';

  @override
  String get deleteDeckMessage => '该牌组中的所有卡片也将被删除。';

  @override
  String get deckDeleted => '牌组已删除';

  @override
  String get addCard => '添加卡片';

  @override
  String get editCard => '编辑卡片';

  @override
  String get deleteCard => '删除';

  @override
  String get word => '单词';

  @override
  String get definition => '定义';

  @override
  String definitionN(int n) {
    return '定义 $n';
  }

  @override
  String get hint => '提示（可选）';

  @override
  String get addAnotherDefinition => '添加另一个定义';

  @override
  String get lookUpDefinitions => '查找定义';

  @override
  String get noDefinitionsFound => '未找到定义。';

  @override
  String get pleaseAddDefinition => '请至少添加一个定义。';

  @override
  String get selectDefinition => '选择要添加的定义';

  @override
  String get deleteCardTitle => '删除卡片？';

  @override
  String get deleteCardMessage => '此卡片将被永久删除。';

  @override
  String get cardDeleted => '卡片已删除';

  @override
  String get noCards => '暂无卡片。\n点击 + 添加您的第一张卡片。';

  @override
  String get practice => '练习';

  @override
  String get addCardTooltip => '添加卡片';

  @override
  String get editCardTooltip => '编辑卡片';

  @override
  String get sessionComplete => '本次学习完成！';

  @override
  String cardsStudied(int count) {
    return '已学习卡片：$count';
  }

  @override
  String get restart => '重新开始';

  @override
  String get backToDeck => '返回牌组';

  @override
  String get deckShuffled => '牌组已打乱！';

  @override
  String get hintLabel => '提示：';

  @override
  String get noHintAvailable => '暂无提示';

  @override
  String get holdForHint => '长按以显示提示';

  @override
  String get switchToLight => '切换到浅色模式';

  @override
  String get switchToDark => '切换到深色模式';

  @override
  String get language => '语言';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get english => '英语';

  @override
  String get spanish => '西班牙语';

  @override
  String get chinese => '中文';

  @override
  String get tapToFlip => '轻触翻转 ';

  @override
  String get skip => '跳';
}
