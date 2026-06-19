import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database.dart' as db;
import '../providers/app_models.dart';
import 'package:shake_gesture/shake_gesture.dart';
import '../canvas/lightbulb_hint_icon.dart';
import '../language/app_localizations.dart';

// This view is for users to practice with the deck of flashcards they made.
// It contains functionality such as the ability to double tap to skip a flashcard (or seperate skip button at the bottom)
// Also allows you to view multiple definitions of a flashcard and a completion screen after you went through all the flashcards in a deck.
// Shaking the phone, triggers the phone's sensor which makes it so we shuffle the deck based on this motion.
// As well, a custom lightbulb icon for the hint and having a long press to reveal the hint.
// The ability to double tap to skip a flashcard and swipe.
class PracticeScreen extends StatefulWidget {
  // This stores the cards along with their definition(s).
  final List<CardWithDefinitions> cards;
  // This is the deck that owns the flashcards that are being practiced on the screen.
  final db.Deck deck;

  const PracticeScreen({
    super.key,
    required this.cards,
    required this.deck,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  // Shuffles the deck.
  late List<CardWithDefinitions> _shuffled;

  // This keep tracks of the index of the card that is currently shown on a user's screen.
  int _index = 0;
  // Keeps track of the definition index.
  int _defIndex = 0;
  // Keeps track of whether the term or definition is currently shown.
  bool _showingTerm = true;
  // This keeps track of whether the user has gone through all the flashcards in a deck or not.
  bool _done = false;
  // This keeps track of how many flashcards the user has studied in a session.
  int _studied = 0;

  // This controls the flipping animation of our flashcard.
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    // This shuffles the deck upon the start of a practice session.
    _shuffled = List.from(widget.cards)..shuffle(Random());
    // Controls the flipping animation of our flashcard.
    // Uses an easeInOut curve for a smooth flipping effect.
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  // Gets the current card being displayed.
  CardWithDefinitions get _current => _shuffled[_index];
  // This method is when a user taps to flip the flashcard to see the definition.
  // Any additional taps will reveal the other definitions if listed on the card.
  // Once all definitions has been tapped through, on the last tap it'll flip back to the word.
  void _onTap() {
    // This if statement makes sure that if a user has already gone through all the flashcards in the deck, 
    // tapping on the flashcard will not do anything.
    if (_done) return;
    setState(() {
      // Flips from the term side to the definition side.
      if (_showingTerm) {
        _showingTerm = false;
        // This starts the flipping animation from the beginning (0) to the end (1).
        _flipCtrl.forward(from: 0);
      } else {
        // This checks if there are multiple definitions and if the user has not yet tapped through all the definitions.
        final defs = _current.definitions;
        if (defs.length > 1 && _defIndex < defs.length - 1) {
          _defIndex++;
        } else {
          _showingTerm = true;
          _defIndex = 0;
          _flipCtrl.reverse(from: 1);
        }
      }
    });
  }

  // This allows us to move on to the next flashcard in the deck.
  // It also marks if you finish the deck once you are on the last card.
  void _nextCard() {
    setState(() {
      // This increases the studied count by 1 every time you move on to the next card.
      _studied++;
      // This checks if the user is on the last card of the deck. If so, it marks the session as done.
      if (_index >= _shuffled.length - 1) {
        _done = true;
      } else {
        _index++;
        _defIndex = 0;
        _showingTerm = true;
        _flipCtrl.value = 0;
      }
    });
  }

  // This goes back to the previously just seen flashcard in the deck. Does not
  // do anything if called when it's the first card of the deck
  void _prevCard() {
    if (_index == 0) return;
    setState(() {
      _studied--;
      _index--;
      _defIndex = 0;
      _showingTerm = true;
      _flipCtrl.value = 0;
    });
  }

  // Displays a pop-up that can be clicked out of. This pop-up will contain the hint
  // that was added on the creation of the card.
  void _showHintOverlay() {
    // This makes sure that if a user tries to long press for a hint when the term is not showing, it will not do anything.
    if (!_showingTerm) return;
    final defs = _current.definitions;
    // In a rare case where somehow a user manages to long press for a hint when there are no definitions, it will also not do anything.
    // We enforce all terms to come with one definition.
    if (defs.isEmpty) return;
    final local = AppLocalizations.of(context)!;
    // This is the hint text that will be shown in the pop-up.
    // If there is no hint provided, it will show a default message indicating that there is no hint available.
    final hint = (_current.card.hint ?? local.noHintAvailable);
    showDialog(
      context: context,
      // This dims the background when the pop-up is shown to focus the user's attention on the hint.
      barrierColor: Colors.black.withAlpha(80),
      builder: (_) {
        final theme = Theme.of(context);
        // This is the UI of the hint pop-up, which includes a custom lightbulb icon and the hint text.
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom lightbulb icon for the hint pop-up.
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CustomPaint(
                        painter: LightbulbPainter(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // This stores the hint text. There is a default message for when there is no hint provided.
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            local.hintLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hint,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // This function preforms a deck shuffle when the app detects a big enough shake
  // gesture and displays a notification at the bottom of the screen indicating the deck
  // has been shuffled.
  void _onShake() {
    final local = AppLocalizations.of(context)!;
    setState(() {
      // Shuffles the deck based on the phone's shake motion.
      _shuffled.shuffle(Random());
      // Sets all the counters and indicators back to the starting point as if you are starting a new practice session.
      _index = 0;
      _defIndex = 0;
      _showingTerm = true;
      _done = false;
      _studied = 0;
      _flipCtrl.value = 0;
    });
    // Brief message at the bottom of the screen to notify the user that the deck has been shuffled.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(local.deckShuffled),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Returns the text of the card. (definition(s))
  String get _cardText {
    if (_showingTerm) return _current.card.term;
    final defs = _current.definitions;
    return defs.isEmpty ? '(no definition)' : defs[_defIndex].content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;
    // This is the completion screen once you completed all the flashcards in a deck.
    if (_done) {
      return ShakeGesture(
        onShake: _onShake,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.deck.title)),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      local.sessionComplete,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      local.cardsStudied(_studied),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    // This button reshuffles the deck and sets all counters back to 0.
                    FilledButton(
                      onPressed: () => setState(() {
                        _shuffled.shuffle(Random());
                        _index = 0;
                        _defIndex = 0;
                        _showingTerm = true;
                        _done = false;
                        _studied = 0;
                        _flipCtrl.value = 0;
                      }),
                      child: Text(local.restart),
                    ),
                    const SizedBox(height: 12),
                    // This button takes the user back to the deck detail screen.
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(local.backToDeck),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // This is the main practice screen UI where the user studies the flashcards.
    // It includes the flashcard display, navigation buttons, and hint functionality.
    return ShakeGesture(
      onShake: _onShake,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.deck.title)),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // This shows the current card index out of the total number of cards in the deck at the top right of the screen.
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_index + 1} / ${_shuffled.length}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              // This is the flashcard display. It includes the flipping animation, the term/definition text, and the hint functionality.
              Expanded(
                child: GestureDetector(
                  // A single tap flips the card or cycles through definitions if there are multiple definitions.
                  onTap: _onTap,
                  // A double tap skips to the next card.
                  onDoubleTap: _nextCard,
                  // A long press reveals the hint for the current card if there is one.
                  onLongPress: _showHintOverlay,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity == null) return;
                    if (details.primaryVelocity! < -100) _nextCard();
                    if (details.primaryVelocity! > 100) _prevCard();
                  },
                  child: AnimatedBuilder(
                    animation: _flipAnim,
                    builder: (context, _) {
                      final angle = _flipAnim.value * pi;
                      final isFront = angle <= pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(isFront ? angle : angle - pi),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isFront
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Text(
                                _cardText,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isFront
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // This shows a hint notification if the current card has a hint when the term side is showing.
              // Prompts the user to long press to view the hint.
              if (_showingTerm &&
                  _current.card.hint != null &&
                  _current.card.hint!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        local.holdForHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(120),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              // Little message to prompt the user to tap to flip the card. Only shows when the term is showing.
              const SizedBox(height: 16),
              Text(
                local.tapToFlip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(120),
                ),
              ),
              const SizedBox(height: 12),
              if (!_showingTerm && _current.definitions.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _current.definitions.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _defIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withAlpha(60),
                        ),
                      ),
                    ),
                  ),
                ),
              // Skip button to skip to the next card without having to double tap the flashcard.
              OutlinedButton.icon(
                icon: const Icon(Icons.skip_next),
                label: Text(local.skip),
                onPressed: _nextCard,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
