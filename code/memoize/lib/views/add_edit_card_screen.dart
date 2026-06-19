import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../providers/card_provider.dart';
import '../dictionary/dictionary_api.dart';
import '../language/app_localizations.dart';

// This view is for when a user creates a new card or editing a card thats already in a deck.

class AddEditCardScreen extends StatefulWidget {
  // Picks up the deck associated with the current card that is being added or modified.
  final int deckId;
  // The actual card being edited, otherwise it is null when creating/adding.
  final Card? card;

  const AddEditCardScreen({
    super.key,
    required this.deckId,
    this.card,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  // Key to make sure all required fields are filled in.
  final _formKey = GlobalKey<FormState>();
  // This controls the word input.
  late final TextEditingController _termCtrl;
  // This controls the hint input. (Optional)
  late final TextEditingController _hintCtrl;
  // This controls the definition(s) inputs.
  late List<TextEditingController> _defCtrls;
  // This boolean checks on the status of the API call to the dictionary.
  // It is true when an API call is being made.
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _termCtrl = TextEditingController(text: widget.card?.term ?? '');
    _hintCtrl = TextEditingController(text: widget.card?.hint ?? '');

    _defCtrls = [TextEditingController()];

    if (widget.card != null) _loadExistingDefinitions();
  }

  // This loads all existing definitions from the database that is associated with the word/term provided.
  Future<void> _loadExistingDefinitions() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final defs = await cardProvider.db.getDefinitionsForCard(widget.card!.id);

    if (!mounted) return;

    setState(() {
      for (final controller in _defCtrls) {
        controller.dispose();
      }
      _defCtrls =
          defs.map((d) => TextEditingController(text: d.content)).toList();

      // This leaves a blank definition entry field always visible.
      // Ex. When adding a card, there will always be at least one blank 'Definition' box where you can type your own definitions in.
      // Any additional definitions that is associated with the word that is pulled from the API creates a new seperate definition field below it.
      if (_defCtrls.isEmpty) _defCtrls = [TextEditingController()];
    });
  }

  @override
  void dispose() {
    _termCtrl.dispose();
    _hintCtrl.dispose();
    for (final c in _defCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // This retrieves/fetches the definition from the Dictionary API
  Future<void> _fetchDefinitions() async {
    final local = AppLocalizations.of(context)!;
    final word = _termCtrl.text.trim();
    if (word.isEmpty) return;

    setState(() => _isFetching = true);

    final defs = await DictionaryAPI.fetchDefinitions(word);

    if (!mounted) return;
    setState(() => _isFetching = false);
    // If the user inputs a word/term and found no definitions with it.
    // It'll show a little popup on the bottom of their screen with the following text message.
    if (defs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.noDefinitionsFound)),
      );
      return;
    }

    _showDefinitionPicker(defs);
  }

  // When a user retrives/fetches the definitions from the API, it'll show a draggable list that you can scroll up and down
  // to browse all the possible definitions.
  // Ex. If you search the word 'apple' you will then see a 'Select a definition to add' and a list of four definitions for apple that you can scroll
  // up and down.
  // Parameters:
  // - defs: Returns the definitions in the form of strings.
  void _showDefinitionPicker(List<String> defs) {
    final local = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              local.selectDefinition,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 12),
            ...defs.map(
              (d) => ListTile(
                title: Text(d),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () {
                  setState(() => _defCtrls.add(TextEditingController(text: d)));
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This validates a successful card created by a user and switches off this screen.
  // Ensures that there is at least one definition listed for the card.
  // If a user fails to provide the require content, they remain on the screen until the required text content is filled.
  Future<void> _save() async {
    final local = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final defs =
        _defCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

    if (defs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.pleaseAddDefinition)),
      );
      return;
    }

    final cardProvider = Provider.of<CardProvider>(context, listen: false);

    if (widget.card == null) {
      // Creates a new card.
      await cardProvider.createCard(
        deckId: widget.deckId,
        term: _termCtrl.text.trim(),
        hint: _hintCtrl.text.trim().isEmpty ? null : _hintCtrl.text.trim(),
        definitions: defs,
      );
    } else {
      // Edit/Update an existing card
      await cardProvider.saveCard(
        widget.card!,
        term: _termCtrl.text.trim(),
        hint: _hintCtrl.text.trim().isEmpty ? null : _hintCtrl.text.trim(),
        definitions: defs,
      );
    }

    if (mounted) Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.card != null ? local.editCard : local.addCard,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            TextFormField(
              controller: _termCtrl,
              decoration: InputDecoration(
                labelText: local.word,
                suffixIcon: _isFetching
                    // This is a loading spinner that shows up when the app is fetching definitions from the API.
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      // This is the search icon that shows up when the app is not fetching definitions from the API.
                      // When a user clicks on this search icon, it will then fetch the definitions from the API
                      // and show them in a draggable list that you can scroll up and down to browse all the possible definitions.
                    : IconButton(
                        tooltip: local.lookUpDefinitions,
                        icon: const Icon(Icons.search),
                        onPressed: _fetchDefinitions,
                      ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? local.required : null,
            ),
            const SizedBox(height: 16),
            ..._defCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        // This labels the definitions if there is more than one definition provided.
                        decoration: InputDecoration(
                          labelText: _defCtrls.length > 1
                              ? local.definitionN(i + 1)
                              : local.definition,
                        ),
                      ),
                    ),
                    // Remove definition button, only shown when there is at least two definition fields.
                    if (_defCtrls.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() => _defCtrls.removeAt(i)),
                      ),
                  ],
                ),
              );
            }),
            // This is the button to add another definition field.
            // When a user clicks on this button, it will then add another definition field below the current definition fields.
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(
                () => _defCtrls.add(TextEditingController()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      local.addAnotherDefinition,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            // Hint Text Field (Optional)
            const SizedBox(height: 8),
            TextFormField(
              controller: _hintCtrl,
              decoration: InputDecoration(labelText: local.hintLabel),
            ),
            // Save Button
            const SizedBox(height: 32),
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
