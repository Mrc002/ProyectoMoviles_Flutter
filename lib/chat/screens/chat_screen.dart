import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../logic/chat_provider.dart';
import '../../features/editor/logic/editor_provider.dart';
import '../../features/settings/logic/language_provider.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colores para los mensajes
    final userMsgColor = theme.colorScheme.primary;
    final aiMsgColor = theme.colorScheme.surface; // Se adaptará a oscuro/claro
    final aiMsgTextColor = theme.colorScheme.onSurface;

    return Column(
      children: [
        // --- LISTA DE MENSAJES ---
        Expanded(
          child: chatProvider.messages.isEmpty
              ? Center(
                  child: Text(
                    l10n.chatVacio,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
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
                          // Usamos los colores dinámicos
                          color: msg.isUser ? userMsgColor : aiMsgColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            if (!msg.isUser)
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                blurRadius: 5,
                              )
                          ],
                        ),
                        child: msg.isUser
                            // El texto del usuario siempre es blanco porque el color primario es oscuro
                            ? Text(msg.text, style: const TextStyle(color: Colors.white))
                            // El texto de la IA se adapta al tema usando Markdown
                            : MarkdownBody(
                                data: msg.text,
                                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                  p: TextStyle(color: aiMsgTextColor)
                                ),
                              ),
                      ),
                    );
                  },
                ),
        ),

        // --- INDICADOR DE CARGA ---
        if (chatProvider.isLoading)
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: theme.colorScheme.primary),
          ),

        // --- INPUT DE TEXTO ---
        Container(
          padding: const EdgeInsets.all(8),
          // El fondo del input container también se adapta
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                // El TextField ya toma el estilo del main.dart automáticamente
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: l10n.chatHint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: theme.colorScheme.primary,
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

    final currentEquation = context.read<EditorProvider>().equation;
    final languageCode = context.read<LanguageProvider>().appLocale.languageCode;

    context.read<ChatProvider>().sendMessage(
      text, 
      currentEquation: currentEquation,
      languageCode: languageCode, 
    );

    _controller.clear();
  }
}