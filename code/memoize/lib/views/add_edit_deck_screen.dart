import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../providers/deck_provider.dart';
import '../language/app_localizations.dart';

// This view is for when a user creates a new deck or editing a previous deck on the same screen.
class AddEditDeckScreen extends StatefulWidget {
  // Deck that is used to be edit. Or otherwise null when creating a new deck.
  final Deck? deck;

  const AddEditDeckScreen({super.key, this.deck});

  @override
  State<AddEditDeckScreen> createState() => _AddEditDeckScreenState();
}

class _AddEditDeckScreenState extends State<AddEditDeckScreen> {
  // This is for the tile of the Deck
  late final TextEditingController _titleCtrl;
  // This is for the description of the deck (Optional)
  late final TextEditingController _descCtrl;
  // Ensures that all required fields are filled in before a user can leave the screen.
  // Ex. If a user went to create a new deck and did not provide a deck name and hit 'Save' it will not let them
  // and highlights the deck name text entry as 'Required'
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.deck?.title ?? '');
    _descCtrl = TextEditingController(text: widget.deck?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // This validates a successful deck created by a user and switches off this screen.
  // If a user fails to provide the require content, they remain on the screen until the required text content is filled.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final deckProvider = Provider.of<DeckProvider>(context, listen: false);

    if (widget.deck == null) {
      // Creates a new deck.
      await deckProvider.createDeck(
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
    } else {
      // Edit/Update an existing deck
      await deckProvider.saveDeck(
        widget.deck!,
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }
  // This builds the UI of the Add/Edit Deck screen, which includes text fields for the deck name and description, and a save button to save the deck.
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.deck != null ? local.editDeck : local.newDeck,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // This is the Deck Name Text Field, which is required.
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: local.deckName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? local.required : null,
            ),
            const SizedBox(height: 16),
            // This is an optional Deck Name Text Field.
            TextFormField(
              controller: _descCtrl,
              decoration:
                  InputDecoration(labelText: local.deckDescription),
            ),
            const SizedBox(height: 32),
            // Save Button
            FilledButton(
              onPressed: _save,
              child: Text(local.save),
            ),
          ],
        ),
      ),
    );
  }
}
