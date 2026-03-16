import 'package:flutter/material.dart';
import '../../chat/logic/chat_provider.dart';
import '../../mecanica_vectorial/screens/ia_tutor_screen.dart'; // Ajusta la ruta si tu IaTutorScreen está en otro lado
import 'package:provider/provider.dart';

class TemaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> tema;

  const TemaDetalleScreen({Key? key, required this.tema}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema['titulo'] ?? 'Detalle del Tema'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiqueta de Bibliografía
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 16, color: Colors.blue[800]),
                    const SizedBox(width: 8),
                    Text(
                      tema['bibliografia'] ?? 'Fuente no especificada',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Aquí irá el contenido del tema extraído de Firebase
              // Suponiendo que en Firebase guardas un campo "contenido"
              Text(
                tema['contenido'] ?? 'El contenido teórico de este tema se cargará aquí. Aquí podrás integrar renderizado de LaTeX si tienes fórmulas matemáticas.',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      // Botón flotante para invocar al tutor EXACTAMENTE sobre este tema
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Le decimos al IA Tutor de qué estamos hablando
          context.read<ChatProvider>().setSection('Ecuaciones Diferenciales: ${tema['titulo']}');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IaTutorScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.psychology),
        label: const Text('Tutor IA'),
      ),
    );
  }
}