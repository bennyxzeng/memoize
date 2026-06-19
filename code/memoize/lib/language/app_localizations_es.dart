// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Memoize';

  @override
  String get newDeck => 'Nueva Baraja';

  @override
  String get editDeck => 'Editar Baraja';

  @override
  String get deleteDeck => 'Eliminar Baraja';

  @override
  String get deckName => 'Nombre de la Baraja';

  @override
  String get deckDescription => 'Descripción (opcional)';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get required => 'Requerido';

  @override
  String get noDecks =>
      'Sin barajas todavía.\nToca + para crear una nueva baraja.';

  @override
  String get deleteDeckTitle => '¿Eliminar Baraja?';

  @override
  String get deleteDeckMessage =>
      'Todas las tarjetas en esta baraja también serán eliminadas.';

  @override
  String get deckDeleted => 'Baraja eliminada';

  @override
  String get addCard => 'Agregar Tarjeta';

  @override
  String get editCard => 'Editar Tarjeta';

  @override
  String get deleteCard => 'Eliminar';

  @override
  String get word => 'Palabra';

  @override
  String get definition => 'Definición';

  @override
  String definitionN(int n) {
    return 'Definición $n';
  }

  @override
  String get hint => 'Pista (opcional)';

  @override
  String get addAnotherDefinition => 'Agregar otra definición';

  @override
  String get lookUpDefinitions => 'Buscar definiciones';

  @override
  String get noDefinitionsFound => 'No se encontraron definiciones.';

  @override
  String get pleaseAddDefinition => 'Por favor agrega al menos una definición.';

  @override
  String get selectDefinition => 'Selecciona una definición para agregar';

  @override
  String get deleteCardTitle => '¿Eliminar Tarjeta?';

  @override
  String get deleteCardMessage =>
      'Esta tarjeta será eliminada permanentemente.';

  @override
  String get cardDeleted => 'Tarjeta eliminada';

  @override
  String get noCards =>
      'Sin tarjetas todavía.\nToca + para agregar tu primera tarjeta.';

  @override
  String get practice => 'Practicar';

  @override
  String get addCardTooltip => 'Agregar Tarjeta';

  @override
  String get editCardTooltip => 'Editar Tarjeta';

  @override
  String get sessionComplete => '¡Sesión Completa!';

  @override
  String cardsStudied(int count) {
    return 'Tarjetas estudiadas: $count';
  }

  @override
  String get restart => 'Reiniciar';

  @override
  String get backToDeck => 'Volver a la Baraja';

  @override
  String get deckShuffled => '¡Baraja mezclada!';

  @override
  String get hintLabel => 'Pista:';

  @override
  String get noHintAvailable => 'Sin pista disponible';

  @override
  String get holdForHint => 'Mantén presionado para revelar la pista';

  @override
  String get switchToLight => 'Cambiar a Modo Claro';

  @override
  String get switchToDark => 'Cambiar a Modo Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get chinese => 'Chino';

  @override
  String get tapToFlip => 'Toca para voltear';

  @override
  String get skip => 'Saltar';
}
