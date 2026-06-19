import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'language/app_localizations.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'providers/theme_provider.dart';
import 'providers/undo_redo_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/card_provider.dart';
import 'providers/language_provider.dart';
import 'views/home_screen.dart';

void main() {
  // This ensures that the flutter framework is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // The database that is shared and used across all providers.
  final db = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        // This provider manages the app's theme (light/dark mode).
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // This provider manages the undo stack for reversible actions across the app.
        ChangeNotifierProvider(create: (_) => UndoProvider()),

        // This provider manages the app's language state and allows for switching between different languages in the UI.
        ChangeNotifierProvider(create: (_) => LanguageProvider()),

        // This provider manages all deck-related database operations along with undo and redo actions.
        ChangeNotifierProxyProvider<UndoProvider, DeckProvider>(
          create: (context) => DeckProvider(
            db: db,
            undoProvider: Provider.of<UndoProvider>(context, listen: false),
          ),
          update: (context, undo, previous) => DeckProvider(
            db: db,
            undoProvider: undo,
          ),
        ),

        // This provider manages all card-related database operations along with undo and redo actions.
        ChangeNotifierProxyProvider<UndoProvider, CardProvider>(
          create: (context) => CardProvider(
            db: db,
            undoProvider: Provider.of<UndoProvider>(context, listen: false),
          ),
          update: (context, undo, previous) => CardProvider(
            db: db,
            undoProvider: undo,
          ),
        ),
      ],
      child: const MemoizeApp(),
    ),
  );
}

// This is the root widget of our application.
// It sets up the MaterialApp and applies theming based on the user's preference (light or dark mode).
class MemoizeApp extends StatelessWidget {
  const MemoizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This stores the current theme provider to access the user's theme preference.
    final themeProvider = Provider.of<ThemeProvider>(context);
    // This stores the current language provider to access the user's language preference.
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Memoize',
      debugShowCheckedModeBanner: false, // Hides the debug banner in the top right corner.
      // This sets up the localization for the app, allowing it to support multiple languages based on the user's preference.
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('zh'),
      ],

      themeMode: themeProvider.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }

  // AI_PROMPT(Perplexity): Asked for help on how to create a light and dark mode that changed the entire app UI using the Brightness enum. I provided
  // a bit of code that I saw from a video tutorial.
  // AI_RESPONSE(Perplexity): It generated the code below which slightly modified my original code.
  // REFLECTION: I originally found a video tutorial about light and dark mode on youtube and while I did have the main functionality working of the color changing
  // from light to dark, not all the things like if I swap to dark mode, the title 'Memoize' that was in black text did not swap to white text. So that's when
  // I prompted AI to help me resolve that problem for me.
  // This is a helper function that builds the ThemeData for both the light and dark mode.
  // Parameters:
  // - brightness: A Brightness value either .light .or .dark.
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF6B7AE8),
      brightness: brightness,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(18)
                : Colors.black.withAlpha(18),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
    );
  }
}
