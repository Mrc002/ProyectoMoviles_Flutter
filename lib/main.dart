import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importar dotenv
import 'app.dart';
import 'features/editor/logic/editor_provider.dart';
import 'features/chat/logic/chat_provider.dart'; // Importar ChatProvider

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Cargar variables de entorno

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()), // <--- AGREGAR ESTO
      ],
      child: const MyApp(),
    ),
  );
}