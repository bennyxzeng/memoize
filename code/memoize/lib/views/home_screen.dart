import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memoize/providers/theme_provider.dart';
import 'package:memoize/providers/language_provider.dart';
import 'package:memoize/providers/undo_redo_provider.dart';
import '../language/app_localizations.dart';
import 'package:memoize/database/database.dart' as db;
import 'package:memoize/providers/deck_provider.dart';
import 'deck_detail_screen.dart';
import 'add_edit_deck_screen.dart';

// This is the main screen of our flashcard app Memoize.
// It shows a list of all decks a user has made. From here, users can navigate to individual deck details or create a new deck.
// Also can toggle Light and Dark Mode from this screen along with changing the language of the UI.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is for accessing the localized strings based on the user's language preference.
    final local = AppLocalizations.of(context)!;
    // This gets the undo provider to manage undo and redo actions across the app.
    final undoProvider = Provider.of<UndoProvider>(context);
    // This is the language provider to manage the app's current language and allow for switching between different languages in the UI.
    final languageProvider = Provider.of<LanguageProvider>(context);

    // This is where we retrive the theme, themeProvider, and deckProvider from the context using a Provider.
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deckProvider = Provider.of<DeckProvider>(context);
    // The Scaffold widget provides the basic visual layout structure for the screen, including an AppBar, body, and a floating action button.
    // The AppBar contains the title of the app and an action button to toggle between light and dark themes.
    // Along with a button to toggle the language of the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          local
              .appTitle, // This is the localized title of the app that changes based on the user's language preference.
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          // Creates a popup menu button that allows users to select their preferred language for the app's UI.
          // The current selection is highlighted in the menu.
          PopupMenuButton<AppLanguage>(
            tooltip: local.language,
            icon: const Icon(Icons.translate),
            // Highlights the current selection in the menu.
            initialValue: languageProvider.language,
            onSelected: (AppLanguage chosen) {
              languageProvider.setLanguage(chosen);
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: AppLanguage.english,
                child: _LangOption(
                  label: local.english,
                  isSelected: languageProvider.language == AppLanguage.english,
                ),
              ),
              PopupMenuItem(
                value: AppLanguage.spanish,
                child: _LangOption(
                  label: local.spanish,
                  isSelected: languageProvider.language == AppLanguage.spanish,
                ),
              ),
              PopupMenuItem(
                value: AppLanguage.chinese,
                child: _LangOption(
                  label: local.chinese,
                  isSelected: languageProvider.language == AppLanguage.chinese,
                ),
              ),
            ],
          ),
          // Light and Dark Mode Toggle Button
          IconButton(
            tooltip: themeProvider.isDark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            icon: Icon(
              themeProvider.isDark
                  ? Icons.wb_sunny_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // Undo and Redo Buttons that only show when there are actions to undo or redo.
          if (undoProvider.canUndo)
            IconButton(
              tooltip: local.undo,
              icon: const Icon(Icons.undo),
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
              icon: const Icon(Icons.redo),
              onPressed: () async {
                await undoProvider.redo();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.redo)),
                  );
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<List<db.Deck>>(
        stream: deckProvider.watchAllDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final decks = snapshot.data ?? [];
          // This is the UI that is shown when there are no decks created yet.
          if (decks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      local.noDecks,
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView.builder(
              itemCount: decks.length,
              itemBuilder: (ctx, i) => _DeckCard(deck: decks[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDeckScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(local.newDeck),
      ),
    );
  }
}

// This widget represents a single language option in the language selection menu.
//It displays the language name and a checkmark if it is the currently selected language.
class _LangOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _LangOption({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }
}

// This widget represents a single deck card in the list of decks on the home screen.
class _DeckCard extends StatelessWidget {
  final db.Deck deck;

  const _DeckCard({required this.deck});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeckDetailScreen(deck: deck),
            ),
          );
        },
        // This is the content of the deck card, which includes the deck title, description, and an edit button to edit the deck details.
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (deck.description != null &&
                        deck.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        deck.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: local.editDeck,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditDeckScreen(deck: deck),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
