import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import 'undo_redo_provider.dart';
import '../providers/app_models.dart';

// This provider manages all deck-related database operations along with undo and redo actions.
class DeckProvider extends ChangeNotifier {
  // The database instance that this provider uses to perform all deck-related database operations.
  final AppDatabase db;
  // The undo provider that this provider uses to register undo and redo actions for deck-related operations.
  final UndoProvider undoProvider;

  DeckProvider({
    required this.db,
    required this.undoProvider,
  });

  Stream<List<Deck>> watchAllDecks() => db.watchAllDecks();

  Future<Deck> getDeckById(int id) => db.getDeckById(id);
  // This method creates a new deck in the database with the specified title and description.
  Future<int> createDeck({
    required String title,
    String? description,
  }) =>
      db.insertDeck(DecksCompanion.insert(
        title: title,
        description: Value(description),
      ));
  // This method updates an existing deck in the database with new title and description.
  Future<void> saveDeck(
    Deck deck, {
    required String title,
    String? description,
  }) async {
    await db.updateDeck(
      deck.toCompanion(true).copyWith(
            title: Value(title),
            description: Value(description),
          ),
    );
  }
  // This method deletes a deck and all of its content from the database.
  Future<void> deleteDeck(Deck deck, List<CardWithDefinitions> cardSnapshots) async {
    await db.deleteDeck(deck.id);

    int? restoredDeckId;

    undoProvider.addUndoAction(
      label: 'deleteDeck',
      undo: () async {
        restoredDeckId = await db.insertDeck(DecksCompanion.insert(
        title: deck.title,
        description: Value(deck.description),
        ));
        for (final cardSnapshot in cardSnapshots) {
          final restoredCardId = await db.insertCard(CardsCompanion.insert(
            deckId: restoredDeckId!,
            term: cardSnapshot.card.term,
            hint: Value(cardSnapshot.card.hint),
          ));
          for (final def in cardSnapshot.definitions) {
            await db.into(db.cardDefinitions).insert(CardDefinitionsCompanion.insert(
              cardId: restoredCardId,
              content: def.content,
            ));
          }
        }
        notifyListeners();
      },
      redo: () async {
        if (restoredDeckId == null) return;
        await db.deleteDeck(restoredDeckId!);
        restoredDeckId = null;
        notifyListeners();
      },
    );
  }
}