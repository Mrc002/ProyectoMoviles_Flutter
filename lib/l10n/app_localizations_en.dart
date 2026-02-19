// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cuenta => 'Account';

  @override
  String get iniciaSesion => 'Log In or Sign Up';

  @override
  String get iniciaSesionSub => 'Save your graphs and chats in the cloud';

  @override
  String get preferencias => 'Preferences';

  @override
  String get temaOscuro => 'Dark Theme';

  @override
  String get idiomaApp => 'App Language';

  @override
  String get acercaDe => 'About';

  @override
  String get acercaDeSub => 'About Math AI Studio';

  @override
  String get editorModo3D => '3D Mode';

  @override
  String get errorConexion => 'Connection error';

  @override
  String get errorGenerar => 'I couldn\'t generate a response.';

  @override
  String get navEstudio => 'Studio';

  @override
  String get navAsistente => 'AI Assistant';

  @override
  String get navAjustes => 'Settings';

  @override
  String get editorFuncion2D => 'Function f(x)';

  @override
  String get editorFuncion3D => 'Function f(x, y)';

  @override
  String get editorHint2D => 'Ex. sin(x) * x';

  @override
  String get editorHint3D => 'Ex. x^2 + y^2';

  @override
  String get chatVacio =>
      'Ask me about your function!\nEx: What is the domain?';

  @override
  String get chatHint => 'Type your question...';

  @override
  String get chatTitle => 'Math Assistant';

  @override
  String get chatEmptySubtitle =>
      'Ask me about your function\nor type an equation to analyze';

  @override
  String get chatSuggestionDomain => 'What is the domain?';

  @override
  String get chatSuggestionIntersect => 'Where does it cross the Y-axis?';

  @override
  String get chatSuggestionExplain => 'Explain the function';

  @override
  String get chatInputHint => 'Ask about your function...';
}
