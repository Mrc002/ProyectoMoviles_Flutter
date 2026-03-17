import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // Librería 100% nativa
import '../../chat/logic/chat_provider.dart';
import '../../chat/screens/chat_screen.dart'; // Navegación al chat oficial

class TemaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> tema;

  const TemaDetalleScreen({Key? key, required this.tema}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema['titulo'] ?? 'Detalle del Tema', overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 25),

              // --- EJEMPLO DE CÓMO SE VERÁ EL CONTENIDO DESDE FIREBASE ---
              const Text(
                'Aquí se cargará la teoría teórica. Observa cómo las fórmulas se renderizan de forma nativa e instantánea:',
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),

              const Text(
                'Una Ecuación Diferencial Lineal de primer orden tiene la forma:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              // FÓRMULA MATEMÁTICA RENDERIZADA EN BLOQUE
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ]
                  ),
                  child: Math.tex(
                    r'\frac{dy}{dx} + P(x)y = Q(x)',
                    textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FÓRMULA MATEMÁTICA EN EL MISMO RENGLÓN (Wrap)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Donde su factor integrante se define como  ',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Math.tex(
                    r'\mu(x) = e^{\int P(x)dx}', 
                    textStyle: TextStyle(fontSize: 18, color: Colors.blue[900])
                  ),
                  const Text(
                    '  para resolverla analíticamente.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
      
      // Botón del Asistente conectado al Chat correcto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<ChatProvider>().setSection('Ecuaciones Diferenciales: ${tema['titulo']}');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.psychology),
        label: const Text('Tutor IA'),
      ),
    );
  }
}