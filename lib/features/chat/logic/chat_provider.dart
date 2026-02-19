import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Modelo simple para guardar los mensajes en memoria
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Historial para la API (formato que espera Gemini REST)
  final List<Map<String, dynamic>> _history = [];

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Instrucción de sistema
  static const _systemInstruction =
      'Eres un profesor experto de matemáticas. '
      'Ayuda a explicar funciones, dominios, rangos, raíces y comportamiento de gráficas. '
      'Sé conciso y claro. Usa notación matemática cuando sea útil.';

  Future<void> sendMessage(String text,
      {String? currentEquation}) async {
    if (text.isEmpty) return;

    _isLoading = true;
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    try {
      // Construir el prompt con contexto de la ecuación actual
      String promptToSend = text;
      if (currentEquation != null && currentEquation.isNotEmpty) {
        promptToSend =
            'El usuario está analizando la función: f(x) = $currentEquation. '
            'Pregunta: $text';
      }

      // Agregar al historial
      _history.add({
        'role': 'user',
        'parts': [
          {'text': promptToSend}
        ],
      });

      final responseText = await _callGeminiAPI();

      // Agregar respuesta al historial
      _history.add({
        'role': 'model',
        'parts': [
          {'text': responseText}
        ],
      });

      _messages.add(ChatMessage(text: responseText, isUser: false));
    } catch (e) {
      // Mensaje de error amigable según el tipo
      String errorMsg = _parseError(e.toString());
      _messages.add(ChatMessage(text: errorMsg, isUser: false));
      // Remover del historial si falló
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _callGeminiAPI() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró GEMINI_API_KEY en el archivo .env');
    }

    // Endpoint REST directo — sin SDK, sin problemas de versiones
    const model = 'gemini-2.0-flash';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      // Instrucción de sistema
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ]
      },
      // Historial de conversación
      'contents': _history,
      // Configuración de generación
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'No pude generar una respuesta.';
    } else {
      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ?? 'Error desconocido';
      throw Exception('${response.statusCode}: $message');
    }
  }

  // Convierte errores técnicos en mensajes amigables
  String _parseError(String error) {
    if (error.contains('429') || error.contains('quota') || error.contains('RESOURCE_EXHAUSTED')) {
      return '⏳ Demasiadas solicitudes seguidas. Espera unos segundos e intenta de nuevo.';
    } else if (error.contains('401') || error.contains('API_KEY') || error.contains('invalid')) {
      return '🔑 La API Key no es válida. Verifica tu archivo .env.';
    } else if (error.contains('timeout') || error.contains('TimeoutException')) {
      return '🌐 La conexión tardó demasiado. Revisa tu internet e intenta de nuevo.';
    } else if (error.contains('GEMINI_API_KEY')) {
      return '⚠️ No se encontró la API Key. Asegúrate de tener el archivo .env configurado.';
    }
    return '❌ Ocurrió un error. Intenta de nuevo en unos momentos.';
  }

  // Limpiar el historial del chat
  void clearChat() {
    _messages.clear();
    _history.clear();
    notifyListeners();
  }
}