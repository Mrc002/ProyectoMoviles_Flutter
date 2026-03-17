import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';

class SistemasSeriesScreen extends StatefulWidget {
  const SistemasSeriesScreen({Key? key}) : super(key: key);

  @override
  State<SistemasSeriesScreen> createState() => _SistemasSeriesScreenState();
}

class _SistemasSeriesScreenState extends State<SistemasSeriesScreen> {
  @override
  void initState() {
    super.initState();
    // Le pedimos al provider que traiga los temas de 'Sistemas'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('Sistemas');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();
    final primaryColor = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistemas y Series'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: Colors.blue[50],
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.temasCargados.length,
                itemBuilder: (context, index) {
                  final tema = provider.temasCargados[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.blue.shade100, width: 1),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.account_tree, color: primaryColor), // Ícono de árbol/sistemas
                      ),
                      title: Text(
                        tema['titulo'] ?? 'Tema sin título',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                      ),
                      subtitle: Text('Fuente: ${tema['bibliografia'] ?? 'Edwards & Penney'}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                      onTap: () {
                        // Navegación al detalle del tema
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemaDetalleScreen(tema: tema),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      
      // BOTÓN QUE ABRE EL BOTTOM SHEET DEL ASISTENTE
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssistant(context, primaryColor),
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  // Lógica para mostrar la hoja inferior deslizable
  void _showAssistant(BuildContext context, Color color) {
    // Contexto general para la IA en esta pantalla
    String contexto = "El usuario está en el menú principal de Sistemas de Ecuaciones y Series de Fourier explorando los temas disponibles, basados en el libro de Edwards & Penney.";
    
    // Configuramos la sección en el Provider
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales (Sistemas y Series)');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => _MiniChatAssistantSistemas(contextoDatos: contexto, colorTema: color)
    );
  }
}

// =========================================================================
// WIDGET DEL MINI-CHAT PARA LA PANTALLA SISTEMAS
// =========================================================================
class _MiniChatAssistantSistemas extends StatefulWidget {
  final String contextoDatos; 
  final Color colorTema;
  
  const _MiniChatAssistantSistemas({required this.contextoDatos, required this.colorTema});
  
  @override
  State<_MiniChatAssistantSistemas> createState() => _MiniChatAssistantSistemasState();
}

class _MiniChatAssistantSistemasState extends State<_MiniChatAssistantSistemas> {
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; 

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, 
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), 
            child: Row(
              children: [
                Icon(Icons.account_tree, color: widget.colorTema), 
                const SizedBox(width: 8), 
                Text(
                  "Tutor IA - Sistemas y Series", 
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
          if (chatProvider.isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0), 
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))
            ),
          Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: "¿Dudas sobre Sistemas o Series?", 
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