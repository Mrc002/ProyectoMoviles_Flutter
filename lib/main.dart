import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
// Importa el nuevo provider
import 'features/editor/logic/editor_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // AQUÍ INYECTAMOS EL CEREBRO DEL EDITOR
        ChangeNotifierProvider(create: (_) => EditorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}