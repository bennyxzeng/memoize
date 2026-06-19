// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Memoize';

  @override
  String get newDeck => 'New Deck';

  @override
  String get editDeck => 'Edit Deck';

  @override
  String get deleteDeck => 'Delete Deck';

  @override
  String get deckName => 'Deck Name';

  @override
  String get deckDescription => 'Description (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get required => 'Required';

  @override
  String get noDecks => 'No decks yet.\nTap + to create a new deck.';

  @override
  String get deleteDeckTitle => 'Delete Deck?';

  @override
  String get deleteDeckMessage =>
      'All cards in this deck will also be deleted.';

  @override
  String get deckDeleted => 'Deck deleted';

  @override
  String get addCard => 'Add Card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get deleteCard => 'Delete';

  @override
  String get word => 'Word';

  @override
  String get definition => 'Definition';

  @override
  String definitionN(int n) {
    return 'Definition $n';
  }

  @override
  String get hint => 'Hint (optional)';

  @override
  String get addAnotherDefinition => 'Add another definition';

  @override
  String get lookUpDefinitions => 'Look up definitions';

  @override
  String get noDefinitionsFound => 'No definitions found.';

  @override
  String get pleaseAddDefinition => 'Please add at least one definition.';

  @override
  String get selectDefinition => 'Select a definition to add';

  @override
  String get deleteCardTitle => 'Delete Card?';

  @override
  String get deleteCardMessage => 'This card will be permanently deleted.';

  @override
  String get cardDeleted => 'Card deleted';

  @override
  String get noCards => 'No cards yet.\nTap + to add your first card.';

  @override
  String get practice => 'Practice';

  @override
  String get addCardTooltip => 'Add Card';

  @override
  String get editCardTooltip => 'Edit Card';

  @override
  String get sessionComplete => 'Session Complete!';

  @override
  String cardsStudied(int count) {
    return 'Cards studied: $count';
  }

  @override
  String get restart => 'Restart';

  @override
  String get backToDeck => 'Back to Deck';

  @override
  String get deckShuffled => 'Deck shuffled!';

  @override
  String get hintLabel => 'Hint:';

  @override
  String get noHintAvailable => 'No hint available';

  @override
  String get holdForHint => 'Tap and hold to reveal hint';

  @override
  String get switchToLight => 'Switch to Light Mode';

  @override
  String get switchToDark => 'Switch to Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get chinese => 'Chinese';

  @override
  String get tapToFlip => 'Tap to flip';

  @override
  String get skip => 'skip';
}
