import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

import 'l10n/app_localizations.dart';
import 'features/editor/logic/editor_provider.dart';
import 'features/settings/logic/language_provider.dart';
import 'features/settings/logic/theme_provider.dart';
import 'chat/logic/chat_provider.dart';
import 'features/auth/logic/auth_provider.dart'; 

// Screens
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // <--- 5. INICIALIZA FIREBASE (Vital para que no crashee)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
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

    const primaryColor = Color(0xFF1E88E5); 
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
          primary: darkPrimaryColor, 
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
            borderSide: const BorderSide(color: darkPrimaryColor), 
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: darkPrimaryColor, 
          unselectedItemColor: Colors.grey,
        ),
      ),
      
      themeMode: themeProvider.themeMode,
      
      // <--- 7. USAMOS EL GUARDIA PARA QUE PASE POR EL LOGIN PRIMERO
      home: const AuthWrapper(),
    );
  }
}

// <--- 8. EL GUARDIA (Decide qué pantalla mostrar)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Si el usuario ya inició sesión (o entró como invitado), va al Home. Si no, al Login.
    if (authProvider.user != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}