import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../providers/undo_redo_provider.dart';
import '../providers/app_models.dart';



// This provider manages all card-related database operations along with undo and redo actions.
class CardProvider extends ChangeNotifier {
  // The database instance that this provider uses to perform all card-related database operations.
  final AppDatabase db;
  // The undo provider that this provider uses to register undo and redo actions for card-related operations.
  final UndoProvider undoProvider;

  CardProvider({
    required this.db,
    required this.undoProvider,
  });
  Stream<List<Card>> watchCardsForDeck(int deckId) =>
      db.watchCardsForDeck(deckId);

  // This method retrieves a list of cards along with their associated definitions for a given deck ID.
  Future<List<CardWithDefinitions>> getCardsWithDefinitions(
      int deckId) async {
    final cards = await db.getCardsForDeck(deckId);
    final result = <CardWithDefinitions>[];

    for (final card in cards) {
      final defs = await db.getDefinitionsForCard(card.id);
      result.add(CardWithDefinitions(card: card, definitions: defs));
    }

    return result;
  }

  // This method creates a new card in the database with the specified deck ID, term, hint, and definitions. 
  // It also registers an undo action to delete the card if the user chooses to undo this operation.
  Future<int> createCard({
    required int deckId,
    required String term,
    String? hint,
    required List<String> definitions,
  }) async {
    final cardId = await db.insertCard(CardsCompanion.insert(
      deckId: deckId,
      term: term,
      hint: Value(hint),
    ));
    await db.replaceDefinitionsForCard(cardId, definitions);
    return cardId;
  }
  // This method updates an existing card in the database with new term, hint, and definitions.
  Future<void> saveCard(
    Card card, {
    required String term,
    String? hint,
    required List<String> definitions,
  }) async {
    await db.updateCard(
      card.toCompanion(true).copyWith(
            term: Value(term),
            hint: Value(hint),
          ),
    );
    await db.replaceDefinitionsForCard(card.id, definitions);
  }
  // This method deletes a card and its definitions from the database.
  Future<void> deleteCard(CardWithDefinitions cwd) async {
    await db.deleteCard(cwd.card.id);

    int? restoredId;

    undoProvider.addUndoAction(
      label: 'deleteCard',
      undo: () async {
        if (restoredId != null) return;
        restoredId = await db.insertCard(CardsCompanion.insert(
          deckId: cwd.card.deckId,
          term: cwd.card.term,
          hint: Value(cwd.card.hint),
        ));
        await db.replaceDefinitionsForCard(
          restoredId!,
          cwd.definitions.map((d) => d.content).toList(),
        );
        notifyListeners();
      },
      redo: () async {
        if (restoredId == null) return;
        await db.deleteCard(restoredId!);
        restoredId = null;
        notifyListeners();
      },
    );
  }
}