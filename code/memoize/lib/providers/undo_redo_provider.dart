import 'package:flutter/foundation.dart';
// This provider manages the undo and redo stacks for reversible actions across the app.
class _UndoEntry {
  // Represents a single undoable action with a label and associated functions.
  final String label;
  // The function to call when performing the undo action.
  final Future<void> Function() undo;
  // The function to call when performing the redo action.
  final Future<void> Function() redo;

  const _UndoEntry({
    required this.label,
    required this.undo,
    required this.redo,
  });
}
class UndoProvider extends ChangeNotifier {
  // This stack holds the actions that can be undone, with the most recent action at the end of the list.
  final List<_UndoEntry> _undoStack = [];
  // This stack holds the actions that can be redone after an undo operation.
  final List<_UndoEntry> _redoStack = [];
  // This flag prevents multiple undo/redo operations from being executed simultaneously, which could lead to inconsistent states.
  bool _isBusy = false;
  // These getters allow the UI to determine whether undo and redo actions are currently available.
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // This method adds a new undoable action to the undo stack and clears the redo stack, since a new action invalidates the redo history.
  void addUndoAction({
    required String label,
    required Future<void> Function() undo,
    required Future<void> Function() redo,
  }) {
    _undoStack.add(
      _UndoEntry(label: label, undo: undo, redo: redo),
    );
    _redoStack.clear();
    notifyListeners();
  }
  // This method performs the undo operation for the most recent action on the undo stack. 
  Future<void> undo() async {
    if (_undoStack.isEmpty || _isBusy) return;
    _isBusy = true;

    try {
      final entry = _undoStack.removeLast();
      await entry.undo();
      _redoStack.add(entry);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
  // This method performs the redo operation for the most recent action on the redo stack.
  Future<void> redo() async {
    if (_redoStack.isEmpty || _isBusy) return;
    _isBusy = true;

    try {
      final entry = _redoStack.removeLast();
      await entry.redo();
      _undoStack.add(entry);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}