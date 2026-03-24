import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart'; 
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart'; // Importamos el componente centralizado

class TemaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> tema;

  const TemaDetalleScreen({Key? key, required this.tema}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5); // Un azul estandarizado

    return Scaffold(
      appBar: AppBar(
        title: Text(tema['titulo'] ?? 'Detalle del Tema', overflow: TextOverflow.ellipsis),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiqueta de Bibliografía
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF234060) : primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 16, color: isDark ? Colors.white70 : primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      tema['bibliografia'] ?? 'Fuente no especificada',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Contenido Teórico (Ejemplo con LaTeX Nativo)
              Text(
                'Aquí se cargará la teoría. Observa cómo las fórmulas se renderizan de forma nativa e instantánea:',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),

              Text(
                'Una Ecuación Diferencial Lineal de primer orden tiene la forma:',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 15),

              // FÓRMULA MATEMÁTICA EN BLOQUE
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.blue.shade100),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ]
                  ),
                  child: Math.tex(
                    r'\frac{dy}{dx} + P(x)y = Q(x)',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FÓRMULA MATEMÁTICA EN EL MISMO RENGLÓN
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Donde su factor integrante se define como  ',
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  ),
                  Math.tex(
                    r'\mu(x) = e^{\int P(x)dx}', 
                    textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : Colors.blue[900])
                  ),
                  Text(
                    '  para resolverla analíticamente.',
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssistant(context, primaryColor, tema),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text('Tutor IA', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAssistant(BuildContext context, Color color, Map<String, dynamic> tema) {
    String contexto = "Tema de Ecuaciones Diferenciales: ${tema['titulo']}. Basado en el libro: ${tema['bibliografia']}. El usuario está leyendo la teoría.";
    
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: ${tema['titulo']}',
        contextoDatos: contexto,
        colorTema: color,
      )
    );
  }
}