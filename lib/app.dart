import 'package:flutter/material.dart';
// Importamos la pantalla principal (Home) que contiene el menú de navegación
import 'features/home/screens/home_screen.dart'; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math AI Studio',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "Debug" de la esquina

      // --- CONFIGURACIÓN DEL TEMA (Basado en tu PDF) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        
        // Color principal: Azul fuerte (Digital Blue)
        primaryColor: const Color(0xFF1E88E5),
        
        // Color de fondo: Un blanco azulado muy suave para no cansar la vista
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        
        // Estilo limpio para las barras superiores
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        
        // Estilo para las tarjetas
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),

      // La aplicación arranca mostrando el HomeScreen
      home: const HomeScreen(),
    );
  }
}