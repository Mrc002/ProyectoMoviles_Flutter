import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/editor/logic/editor_provider.dart';
import 'features/chat/logic/chat_provider.dart'; // Importar ChatProvider
import 'features/settings/logic/theme_provider.dart';
import 'features/settings/logic/language_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Cargar variables de entorno
void main() {
  runApp(
    MultiProvider(
      providers: [
        // AQUÍ INYECTAMOS EL CEREBRO DEL EDITOR
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),

      ],
      child: const MyApp(),
    ),
  );
}