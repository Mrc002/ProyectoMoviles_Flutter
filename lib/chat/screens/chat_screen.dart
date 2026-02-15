import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../logic/chat_provider.dart';
import '../../features/editor/logic/editor_provider.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    // Corrección 1: Se eliminó la variable 'editorProvider' que no se usaba aquí.

    return Column(
      children: [
        // --- LISTA DE MENSAJES ---
        Expanded(
          child: chatProvider.messages.isEmpty
              ? const Center(
                  child: Text(
                    "¡Pregúntame sobre tu función!\nEj: ¿Cuál es el dominio?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatProvider.messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        decoration: BoxDecoration(
                          color: msg.isUser ? Theme.of(context).primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (!msg.isUser)
                              BoxShadow(
                                // Corrección 2: Usar withValues(alpha: ...) en lugar de withOpacity
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                              )
                          ],
                        ),
                        child: msg.isUser
                            ? Text(msg.text, style: const TextStyle(color: Colors.white))
                            // Usamos Markdown para la respuesta de la IA
                            : MarkdownBody(data: msg.text),
                      ),
                    );
                  },
                ),
        ),

        // --- INDICADOR DE CARGA ---
        if (chatProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),

        // --- INPUT DE TEXTO ---
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Escribe tu duda...",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: Theme.of(context).primaryColor,
                onPressed: () => _sendMessage(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    // Obtenemos la ecuación que está en el EditorProvider
    final currentEquation = context.read<EditorProvider>().equation;

    // Enviamos el mensaje junto con la ecuación como contexto
    context.read<ChatProvider>().sendMessage(text, currentEquation: currentEquation);

    _controller.clear();
  }
}