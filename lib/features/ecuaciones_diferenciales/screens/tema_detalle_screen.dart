import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart'; 
import '../../chat/logic/chat_provider.dart';

class TemaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> tema;

  const TemaDetalleScreen({Key? key, required this.tema}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue[800]!; // El color principal de esta materia

    return Scaffold(
      appBar: AppBar(
        title: Text(tema['titulo'] ?? 'Detalle del Tema', overflow: TextOverflow.ellipsis),
        backgroundColor: primaryColor,
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
                    Icon(Icons.menu_book, size: 16, color: primaryColor),
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

              // Contenido Teórico (Ejemplo con LaTeX Nativo)
              const Text(
                'Aquí se cargará la teoría. Observa cómo las fórmulas se renderizan de forma nativa e instantánea:',
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),

              const Text(
                'Una Ecuación Diferencial Lineal de primer orden tiene la forma:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 15),

              // FÓRMULA MATEMÁTICA EN BLOQUE
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

              // FÓRMULA MATEMÁTICA EN EL MISMO RENGLÓN
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
      
      // --- MODIFICADO: BOTÓN QUE ABRE EL BOTTOM SHEET DEL ASISTENTE ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssistant(context, primaryColor, tema),
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.psychology),
        label: const Text('Tutor IA'),
      ),
    );
  }

  // Lógica para mostrar la hoja inferior deslizable
  void _showAssistant(BuildContext context, Color color, Map<String, dynamic> tema) {
    // Definimos el contexto que la IA necesita saber antes de chatear
    String contexto = "Tema de Ecuaciones Diferenciales: ${tema['titulo']}. Basado en el libro: ${tema['bibliografia']}. El usuario está leyendo la teoría de este tema específico y puede tener dudas analíticas o de los métodos de resolución.";
    
    // Configuramos en el Provider la sección actual (Opcional, pero bueno para tu historial)
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales: ${tema['titulo']}');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => _MiniChatAssistantEcuaciones(contextoDatos: contexto, colorTema: color)
    );
  }
}


class _MiniChatAssistantEcuaciones extends StatefulWidget {
  final String contextoDatos; 
  final Color colorTema;
  
  const _MiniChatAssistantEcuaciones({required this.contextoDatos, required this.colorTema});
  
  @override
  State<_MiniChatAssistantEcuaciones> createState() => _MiniChatAssistantEcuacionesState();
}

class _MiniChatAssistantEcuacionesState extends State<_MiniChatAssistantEcuaciones> {
  final _controller = TextEditingController();
  
  @override
  void dispose() { 
    _controller.dispose(); 
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // Para subir el teclado

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, 
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        children: [
          // HEADER DEL MINI CHAT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), 
            child: Row(
              children: [
                Icon(Icons.functions, color: widget.colorTema), // Ícono de matemáticas
                const SizedBox(width: 8), 
                Text(
                  "Tutor IA - Ecuaciones", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))
                ), 
                const Spacer(), 
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), 
                  onPressed: () => Navigator.pop(context)
                )
              ]
            )
          ),
          
          // LISTA DE MENSAJES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: chatProvider.messages.length, 
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, 
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8), 
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), 
                    decoration: BoxDecoration(
                      color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFE8EAF6)), 
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(0) : null, 
                        bottomLeft: !msg.isUser ? const Radius.circular(0) : null
                      )
                    ), 
                    child: Text(
                      msg.text, 
                      style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))
                    )
                  )
                );
              }
            )
          ),
          
          // INDICADOR DE CARGA DE LA IA
          if (chatProvider.isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0), 
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))
            ),
          
          // BARRA DE TEXTO PARA ESCRIBIR
          Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: "¿Tienes alguna duda del tema?", 
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), 
                      filled: true, 
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    )
                  )
                ),
                const SizedBox(width: 8), 
                CircleAvatar(
                  backgroundColor: widget.colorTema, 
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
                    onPressed: () { 
                      if (_controller.text.isNotEmpty) { 
                        // Envía el mensaje y le pasa el contexto teórico a la IA
                        chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); 
                        _controller.clear(); 
                      } 
                    }
                  )
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}