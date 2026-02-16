import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Modelo simple para guardar los mensajes en memoria
class ChatMessage {
  final String text;
  final bool isUser; // true = Usuario, false = IA
  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider extends ChangeNotifier {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Getters para la UI
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initModel();
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      debugPrint('Error: No se encontró GEMINI_API_KEY en el archivo .env');
      return;
    }
    // Usamos 'gemini-pro' que es ideal para texto y chat
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview', // Versión rápida y eficiente
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.7),
    );
    
    // Iniciamos la sesión de chat con una instrucción de sistema "simulada" en el historial
    _chat = _model.startChat(history: [
      Content.text('Eres un profesor experto de matemáticas. Ayuda a explicar funciones, dominios y rangos. Sé conciso.'),
      Content.model([TextPart('Entendido. Seré tu asistente matemático.')]),
    ]);
  }

// Función para enviar mensajes (Ahora recibe languageCode)
  Future<void> sendMessage(String text, {String? currentEquation, required String languageCode}) async {
    if (text.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Mostrar mensaje del usuario
      _messages.add(ChatMessage(text: text, isUser: true));
      
      // 2. Construir el prompt con contexto de la ecuación y el IDIOMA
      String promptToSend = text;
      bool isEnglish = languageCode == 'en';

      if (currentEquation != null && currentEquation.isNotEmpty) {
        promptToSend = isEnglish
            ? "The user is analyzing the mathematical function: $currentEquation. Question: $text. IMPORTANT: You must answer exclusively in English."
            : "El usuario está analizando la función matemática: $currentEquation. Pregunta: $text. IMPORTANTE: Debes responder exclusivamente en Español.";
      } else {
        promptToSend = isEnglish
            ? "$text\n\n(IMPORTANT: You must answer exclusively in English)"
            : "$text\n\n(IMPORTANTE: Debes responder exclusivamente en Español)";
      }

      // 3. Enviar a Gemini
      final response = await _chat.sendMessage(Content.text(promptToSend));
      
      final errorMsg = isEnglish ? "I couldn't generate a response." : "No pude generar una respuesta.";
      final responseText = response.text ?? errorMsg;

      // 4. Mostrar respuesta de la IA
      _messages.add(ChatMessage(text: responseText, isUser: false));

    } catch (e) {
      bool isEnglish = languageCode == 'en';
      final errorPrefix = isEnglish ? "Connection error" : "Error de conexión";
      _messages.add(ChatMessage(text: "$errorPrefix: $e", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}