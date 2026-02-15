import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'features/editor/logic/editor_provider.dart';
import 'chat/logic/chat_provider.dart';
import 'features/settings/logic/theme_provider.dart';
import 'features/settings/logic/language_provider.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén listos antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Carga las variables de entorno
  await dotenv.load(fileName: ".env"); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}