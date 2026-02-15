import 'package:flutter/material.dart';
import '../../editor/screens/editor_screen.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../settings/screens/settings_screen.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Estudio', // Tu graficadora unificada
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Asistente IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}