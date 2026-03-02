import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelo simple para guardar los mensajes en memoria
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// Crea un modelo simple para la sesión de chat en el menú
class ChatSession {
  final String id;
  final String title;
  ChatSession({required this.id, required this.title});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Historial para la API (formato que espera Gemini REST)
  final List<Map<String, dynamic>> _history = [];

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentChatId;
  List<ChatSession> _chatSessions = [];
  String _currentLanguage = 'es'; // Variable para el idioma

  List<ChatSession> get chatSessions => _chatSessions;

  // Llama a esto cuando inicies la app o cuando inicie sesión un usuario registrado
  Future<void> fetchUserChats() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .get();

      _chatSessions = snapshot.docs.map((doc) {
        return ChatSession(
          id: doc.id,
          title: doc['title'] ?? 'Nuevo Chat',
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error obteniendo chats: $e");
    }
  }

  // --- INSTRUCCIÓN DE SISTEMA DINÁMICA (usa el idioma actual) ---
  String get _systemInstruction =>
      'Eres un profesor de matemáticas experto y amigable en una app de graficación.\n'
      'Responde SIEMPRE en el idioma con código: $_currentLanguage.\n'
      'Reglas:\n'
      '1. Explica los conceptos de forma clara, didáctica y conversacional.\n'
      '2. Si tienes que mostrar una fórmula matemática, fracciones, integrales o ecuaciones, SIEMPRE usa el formato LaTeX envuelto en símbolos de dólar. Por ejemplo: \$x^2 + y^2 = r^2\$ o \$\$\\frac{1}{2}\$\$.\n'
      '3. Usa negritas y viñetas para organizar tu texto.\n'
      '4. Si el usuario pide datos o comparaciones, genérale tablas en formato Markdown.';

  // --- PARÁMETRO languageCode AGREGADO ---
  Future<void> sendMessage(String text, {String? currentEquation, String? languageCode}) async {
    if (text.isEmpty) return;

    // Actualizar el idioma si se proporciona
    if (languageCode != null && languageCode.isNotEmpty) {
      _currentLanguage = languageCode;
    }

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

      // Guardar en Firebase
      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        await _saveChatToFirestore(text, responseText, user.uid);
      }

    } catch (e) {
      String errorMsg = _parseError(e.toString());
      _messages.add(ChatMessage(text: errorMsg, isUser: false));
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Lógica para guardar en Firestore ---
  Future<void> _saveChatToFirestore(String userText, String botResponse, String uid) async {
    final chatRef = _firestore.collection('users').doc(uid).collection('chats');

    try {
      if (_currentChatId == null) {
        final newChat = await chatRef.add({
          'title': userText,
          'createdAt': FieldValue.serverTimestamp(),
          'messages': [
            {'text': userText, 'isUser': true},
            {'text': botResponse, 'isUser': false},
          ]
        });
        _currentChatId = newChat.id;
        await fetchUserChats();
      } else {
        await chatRef.doc(_currentChatId).update({
          'messages': FieldValue.arrayUnion([
            {'text': userText, 'isUser': true},
            {'text': botResponse, 'isUser': false},
          ])
        });
      }
    } catch (e) {
      debugPrint("Error guardando en Firestore: $e");
    }
  }

  // --- Cargar un chat antiguo desde el menú lateral ---
  Future<void> loadChatSession(String chatId) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    _isLoading = true;
    _currentChatId = chatId;
    _messages.clear();
    _history.clear();
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).collection('chats').doc(chatId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final msgs = data['messages'] as List<dynamic>;
        
        for (var msg in msgs) {
          final text = msg['text'] as String;
          final isUser = msg['isUser'] as bool;
          
          _messages.add(ChatMessage(text: text, isUser: isUser));
          _history.add({
            'role': isUser ? 'user' : 'model',
            'parts': [{'text': text}],
          });
        }
      }
    } catch (e) {
      debugPrint("Error cargando historial de chat: $e");
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

    const model = 'gemini-3-flash-preview';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction} // Ahora usa el getter dinámico
        ]
      },
      'contents': _history,
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
        .timeout(const Duration(seconds: 360));

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

  // Limpiar el historial para iniciar un nuevo chat
  void clearChat() {
    _currentChatId = null;
    _messages.clear();
    _history.clear();
    notifyListeners();
  }
}