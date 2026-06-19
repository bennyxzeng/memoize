import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart' as db;
import '../providers/card_provider.dart';
import '../providers/deck_provider.dart';
import '../providers/app_models.dart';
import 'package:memoize/views/add_edit_card_screen.dart';
import 'package:memoize/views/practice_screen.dart';
import '../language/app_localizations.dart';
import '../providers/undo_redo_provider.dart';

// This view is for showing the details of a specific deck that a user has selected.
// It shows all the cards in that deck and allows users to add, edit, or delete cards.
class DeckDetailScreen extends StatelessWidget {
  // The deck that is being shown in this screen.
  final db.Deck deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final cardProvider = Provider.of<CardProvider>(context);
    final local = AppLocalizations.of(context)!;
    final undoProvider = Provider.of<UndoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          if (undoProvider.canUndo)
            IconButton(
              tooltip: local.undo,
              icon: const Icon(Icons.undo_outlined),
              onPressed: () async {
                await undoProvider.undo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.undo)),
                  );
                }
              },
            ),
          if (undoProvider.canRedo)
            IconButton(
              tooltip: local.redo,
              icon: const Icon(Icons.redo_outlined),
              onPressed: () async {
                await undoProvider.redo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.redo)),
                  );
                }
              }
            ),
          // This deletes the deck and all the cards in it.
          // It also shows a confirmation dialog to confirm deletion.
          IconButton(
            tooltip: local.deleteDeck,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(local.deleteDeckTitle),
                  content: Text(
                      local.deleteDeckMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(local.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(local.delete),
                    ),
                  ],
                ),
              );
              // This makes sure that the Deck Provider also deletes the content.
              if (confirmed == true && context.mounted) {
                final cardSnapshots = await cardProvider.getCardsWithDefinitions(deck.id);
                await deckProvider.deleteDeck(deck, cardSnapshots);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              }
            },
          ),
        ],
      ),
      // This keep tracks of the cards in the deck and updates
      // in real time as cards are added, edited, or deleted.
      body: StreamBuilder<List<db.Card>>(
        stream: cardProvider.watchCardsForDeck(deck.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snapshot.data ?? [];
          // This is the UI that is shown when there are no cards in the deck.
          if (cards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.style_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      local.noCards,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // This is for when the deck has at least one card. It shows the list of cards and a button to start practicing.
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(local.practice),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    // This loads all the card definitions for the practice screen.
                    onPressed: () async {
                      final cwds =
                          await cardProvider.getCardsWithDefinitions(deck.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PracticeScreen(
                              cards: cwds,
                              deck: deck,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (ctx, i) =>
                      _CardTile(card: cards[i], deck: deck),
                ),
              ),
            ],
          );
        },
      ),
      // This is a button to add cards to a deck.
      floatingActionButton: FloatingActionButton(
        tooltip: local.addCardTooltip,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditCardScreen(deckId: deck.id),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  // The card to display.
  final db.Card card;
  // The deck where we are editing cards from.
  final db.Deck deck;

  const _CardTile({required this.card, required this.deck});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final local = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          card.term,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        // This is for when a user wants to see a hint and also check if their a hint description provided.
        subtitle: (card.hint != null && card.hint!.isNotEmpty)
            ? Text(
                '${local.hintLabel} ${card.hint!}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Icon Button that users can press to edit a specific card
            IconButton(
              tooltip: local.editCardTooltip,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCardScreen(
                    deckId: deck.id,
                    card: card,
                  ),
                ),
              ),
            ),
            // Icon Button to delete a card and its content from the deck.
            IconButton(
              tooltip: local.deleteCard,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(local.deleteCardTitle),
                    content:
                        Text(local.deleteCardMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(local.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(local.delete),
                      ),
                    ],
                  ),
                );
                // This makes sure that the Card Provider also deletes the content.
                if (confirmed == true && context.mounted) {
                  final defs =
                      await cardProvider.db.getDefinitionsForCard(card.id);
                  final cwd = CardWithDefinitions(
                    card: card,
                    definitions: defs,
                  );
                  await cardProvider.deleteCard(cwd);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
