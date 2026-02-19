import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/settings/logic/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'features/settings/logic/language_provider.dart';

// ─── PALETA DE COLORES CENTRALIZADA ───────────────────────────────────────────
// Inspirada en la referencia: azul cielo suave, cards blancas, acento naranja
class AppColors {
  // Primarios
  static const skyBlue       = Color(0xFF5B9BD5);   // Azul principal (header/buttons)
  static const skyBlueDark   = Color(0xFF3A7FC1);   // Azul oscuro (hover/pressed)
  static const skyBlueLight  = Color(0xFFD6E8F7);   // Azul muy claro (backgrounds)
  static const skyBluePale   = Color(0xFFEBF4FC);   // Azul casi blanco (scaffold bg)

  // Acento
  static const accent        = Color(0xFFF5A623);   // Naranja/ámbar (acento cálido)
  static const accentLight   = Color(0xFFFFF3E0);   // Naranja pálido

  // Neutros
  static const white         = Color(0xFFFFFFFF);
  static const cardBg        = Color(0xFFFFFFFF);
  static const surface       = Color(0xFFF0F7FF);
  static const textPrimary   = Color(0xFF1A2D4A);   // Azul muy oscuro (títulos)
  static const textSecondary = Color(0xFF6B8CAE);   // Azul grisáceo (subtítulos)
  static const divider       = Color(0xFFD6E8F7);

  // Modo oscuro
  static const darkBg        = Color(0xFF0F1E2E);
  static const darkSurface   = Color(0xFF152840);
  static const darkCard      = Color(0xFF1C3350);
  static const darkBorder    = Color(0xFF234060);
}
// ──────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider    = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Math AI Studio',
      debugShowCheckedModeBanner: false,

      // ── Localización ──────────────────────────────────────────────────────
      locale: languageProvider.appLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],

      themeMode: themeProvider.themeMode,

      // ── TEMA CLARO ────────────────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.skyBlue,
        scaffoldBackgroundColor: AppColors.skyBluePale,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary:         AppColors.skyBlue,
          onPrimary:       AppColors.white,
          secondary:       AppColors.accent,
          onSecondary:     AppColors.white,
          surface:         AppColors.white,
          onSurface:       AppColors.textPrimary,
          error:           Color(0xFFE53935),
          onError:         AppColors.white,
        ),

        // AppBar con el azul del header de la referencia
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColors.white),
        ),

        // Cards blancas con sombra suave
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardBg,
          shadowColor: Color(0x1A3A7FC1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.skyBlueLight, width: 1.5),
          ),
        ),

        // Inputs con borde azul suave
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.skyBlueLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.skyBlueLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),

        // Botones elevados con el azul principal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // TextButtons con el azul
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.skyBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // BottomNav con fondo blanco y selección azul
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.skyBlue,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),

        // Switch con azul
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.skyBlue;
            return Colors.grey.shade400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.skyBlueLight;
            return Colors.grey.shade200;
          }),
        ),

        dividerColor: AppColors.divider,
      ),

      // ── TEMA OSCURO ───────────────────────────────────────────────────────
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.skyBlue,
        scaffoldBackgroundColor: AppColors.darkBg,

        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary:         AppColors.skyBlue,
          onPrimary:       AppColors.white,
          secondary:       AppColors.accent,
          onSecondary:     AppColors.white,
          surface:         AppColors.darkCard,
          onSurface:       Colors.white,
          error:           Color(0xFFEF5350),
          onError:         AppColors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white38),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF82C4F8),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.skyBlue,
          unselectedItemColor: Colors.white38,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.skyBlue;
            return Colors.grey.shade600;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.darkBorder;
            return Colors.grey.shade800;
          }),
        ),

        dividerColor: AppColors.darkBorder,
      ),

      home: const _AuthWrapper(),
    );
  }
}

// Wrapper de autenticación (mantiene la lógica existente)
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}