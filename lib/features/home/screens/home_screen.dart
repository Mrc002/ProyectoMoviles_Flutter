import 'package:flutter/material.dart';
import '../../editor/screens/editor_screen.dart';
import '../../chat/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // --- CORRECCIÓN AQUÍ ---
  // Quitamos el "const" global de la lista para evitar conflictos si alguna pantalla no lo es.
  // Quitamos el "Center" y el "style" que sobraban en ChatScreen.
  final List<Widget> _screens = [
    const EditorScreen(), 
    const ChatScreen(), 
    const Center(
      child: Text(
        'Ajustes y Perfil', 
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar limpio
      appBar: AppBar(
        title: const Text('Math AI Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      
      // IndexedStack mantiene el estado de las pantallas (no se borran al cambiar de pestaña)
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Estudio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology), // Icono de cerebro/IA
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