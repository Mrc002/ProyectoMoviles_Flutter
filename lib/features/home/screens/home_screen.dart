import 'package:flutter/material.dart';
import '../../editor/screens/editor_screen.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../l10n/app_localizations.dart'; // <-- 1. Importación del traductor

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas. La primera es tu Editor con zoom infinito.
  final List<Widget> _screens = const [
    EditorScreen(), 
    ChatScreen(),
    SettingsScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    // 2. Instanciamos el traductor para usarlo en esta pantalla
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Mantenemos el AppBar limpio
      appBar: AppBar(
        title: const Text('Math AI Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: Colors.white,
      ),
      
      // Aquí se muestra la pantalla seleccionada
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Para que no se muevan los iconos
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: l10n.navEstudio, // <-- 3. Usamos la variable de traducción
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology),
            label: l10n.navAsistente, // <-- Usamos la variable de traducción
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navAjustes, // <-- Usamos la variable de traducción
          ),
        ],
      ),
    );
  }
}