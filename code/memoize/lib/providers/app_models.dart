import '../database/database.dart';

// This class is used to make sure a card has the correct associcated list of definitions.
class CardWithDefinitions {
  // This pulls the card from the database
  final Card card;
  // This puts all the definitions into a list.
  final List<CardDefinition> definitions;

  
  const CardWithDefinitions({
    required this.card,
    required this.definitions,
  });
}