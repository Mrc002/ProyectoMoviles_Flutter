import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'features/editor/logic/editor_provider.dart';
import 'features/settings/logic/language_provider.dart';
import 'features/settings/logic/theme_provider.dart';
import 'chat/logic/chat_provider.dart';

// Screens
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // ¡De vuelta a tu azul original!
    const primaryColor = Color(0xFF1E88E5); 
    // Un azul ligeramente más claro para que no se pierda en el modo oscuro
    const darkPrimaryColor = Color(0xFF64B5F6); 

    return MaterialApp(
      title: 'Math AI Studio',
      debugShowCheckedModeBanner: false,
      
      // --- CONFIGURACIÓN DE IDIOMA ---
      locale: languageProvider.appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // --- TEMA CLARO (LIGHT) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: primaryColor,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),

      // --- TEMA OSCURO (DARK) PROFESIONAL ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), 
        colorScheme: const ColorScheme.dark(
          primary: darkPrimaryColor, // Usamos el azul claro aquí
          surface: Color(0xFF1E1E1E), 
          onSurface: Colors.white, 
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C), 
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkPrimaryColor), // Bordes azules al escribir
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: darkPrimaryColor, // Iconos del menú en azul
          unselectedItemColor: Colors.grey,
        ),
      ),
      
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}