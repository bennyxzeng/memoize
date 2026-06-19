import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// -- TABLES --

// This class is used to represent the different decks and their properties. Used to store the data of the decks in the database.
// Each deck has their own title, description, and timestamp of when it was created/last modified.
class Decks extends Table {
  // This gets the unieque id of the deck, which is auto-incremented by the database.
  IntColumn get id => integer().autoIncrement()();
  // This gets the title of the deck. (Required, max length of 100 characters)
  TextColumn get title => text().withLength(min: 1, max: 100)();
  // This gets the description of the deck. (Optional)
  TextColumn get description => text().nullable()();
  // These are used to get the timestamps of when the deck was created and last modified.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}


// This class is used to represent the different cards and their properties. Used to store the data of the cards in the database.
// Each card has a term, hint (optional), and timestamp of when it was created/last modified and is associated with a deck.
class Cards extends Table {
  // This gets the unique id of the card, which is auto-incremented by the database.
  IntColumn get id => integer().autoIncrement()();
  // This links the card to a specific deck by referencing the deck's id.
  IntColumn get deckId => integer().references(Decks, #id)();
  // This gets the term of the card. (Required)
  TextColumn get term => text().withLength(min: 1, max: 200)();
  // This gets the hint of the card. (Optional)
  TextColumn get hint => text().nullable()();
  // This keep tracks of when the card was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// This class is used to represent the different definitions of a card and their properties. Used to store the data of the definitions in the database.
// Each card can have multiple definitions and is in a sorted order.
class CardDefinitions extends Table {
  // This gets the unique id of the definition, which is auto-incremented by the database.
  IntColumn get id => integer().autoIncrement()();
  // This links the definition to a specific card by referencing the card's id.
  IntColumn get cardId => integer().references(Cards, #id)();
  // This gets the content of the definition.
  TextColumn get content => text().withLength(min: 1, max: 500)();
  // This is used when a card has multiple definitions. It keeps track of the order of the definitions for a card.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// -- DATABASE --

// The database that stores our deck, cards, and their definitions.
@DriftDatabase(tables: [Decks, Cards, CardDefinitions])
class AppDatabase extends _$AppDatabase {
  // This constructors tells Drift where the database is stored and created.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
  // This helps with creating the tables and migrating the database when changes are made to the tables.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );


  // -- Deck Database Access Objects (DAOs) --
  Stream<List<Deck>> watchAllDecks() => select(decks).watch();
  // This gets a deck by their ID.
  // Returns the deck of the given ID.
  Future<Deck> getDeckById(int id) =>
      (select(decks)..where((d) => d.id.equals(id))).getSingle();
  // This inserts a new deck into the database.
  Future<int> insertDeck(DecksCompanion entry) => into(decks).insert(entry);
  // This replaces an existing deck with new content/values.
  Future<bool> updateDeck(DecksCompanion entry) =>
      update(decks).replace(entry);
  // This deletes a deck and all content within.
  Future<int> deleteDeck(int id) async {
    final cardIds = await (select(cards)..where((c) => c.deckId.equals(id)))
        .map((c) => c.id)
        .get();
    for (final cid in cardIds) {
      await deleteCard(cid);
    }
    return (delete(decks)..where((d) => d.id.equals(id))).go();
  }

  // -- Card DAOs --

  Stream<List<Card>> watchCardsForDeck(int deckId) =>
      (select(cards)..where((c) => c.deckId.equals(deckId))).watch();
  // This retrieves all cards inside of a given deck.
  Future<List<Card>> getCardsForDeck(int deckId) =>
      (select(cards)..where((c) => c.deckId.equals(deckId))).get();
  // This inserts a new card into the database.
  Future<int> insertCard(CardsCompanion entry) => into(cards).insert(entry);
  // This updates/replaces a card with new content/values.
  Future<bool> updateCard(CardsCompanion entry) =>
      update(cards).replace(entry);
  // This deletes a card and their definition(s).
  Future<int> deleteCard(int id) async {
    await (delete(cardDefinitions)..where((d) => d.cardId.equals(id))).go();
    return (delete(cards)..where((c) => c.id.equals(id))).go();
  }

  // -- Definition DAOs -- 
  // This grabs all the definitions for a card and sort the definitions in a specific order.
  Future<List<CardDefinition>> getDefinitionsForCard(int cardId) =>
      (select(cardDefinitions)
            ..where((d) => d.cardId.equals(cardId))
            ..orderBy([(d) => OrderingTerm.asc(d.sortOrder)]))
          .get();
  // This returns a stream of definitions for a given card.
  Stream<List<CardDefinition>> watchDefinitionsForCard(int cardId) =>
      (select(cardDefinitions)
            ..where((d) => d.cardId.equals(cardId))
            ..orderBy([(d) => OrderingTerm.asc(d.sortOrder)]))
          .watch();
  // This replaces the definitions of a card.
  Future<void> replaceDefinitionsForCard(
      int cardId, List<String> texts) async {
    await (delete(cardDefinitions)
          ..where((d) => d.cardId.equals(cardId)))
        .go();
    for (int i = 0; i < texts.length; i++) {
      await into(cardDefinitions).insert(CardDefinitionsCompanion.insert(
        cardId: cardId,
        content: texts[i],
        sortOrder: Value(i),
      ));
    }
  }
}

// Reused from Journal App
// Main purpose is to open the database using Drift.
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'memoize_database',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}