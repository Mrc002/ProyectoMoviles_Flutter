import 'dart:math'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai; 

// Modelo simple para guardar los mensajes en memoria
class ChatMessage {
  String text; 
  final bool isUser;
  bool isTranslating; 
  
  ChatMessage({
    required this.text, 
    required this.isUser,
    this.isTranslating = false,
  });
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

  final _translator = GoogleTranslator();
  final List<Map<String, dynamic>> _history = [];

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentChatId;
  List<ChatSession> _chatSessions = [];
  String _currentLanguage = 'es'; 

  List<ChatSession> get chatSessions => _chatSessions;

  // --- PASO 1: CONSTRUCTOR QUE ESCUCHA LA SESIÓN ---
  ChatProvider() {
    // authStateChanges() nos avisa en tiempo real si el usuario se loguea o se sale
    _auth.authStateChanges().listen((user) {
      if (user != null && !user.isAnonymous) {
        // Si hay un usuario real, mandamos a pedir sus chats guardados
        fetchUserChats();
      } else {
        // Si es invitado o cerró sesión, limpiamos todo para que no vea chats de otros
        clearChat();
        _chatSessions.clear();
        notifyListeners();
      }
    });
  }

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
      // --- PASO 2: AUTO-CARGAR LA ÚLTIMA CONVERSACIÓN ---
      // Verificamos dos cosas:
      // 1. _currentChatId == null (Significa que la pantalla de chat está vacía)
      // 2. _chatSessions.isNotEmpty (Significa que el usuario sí tiene chats guardados)
      if (_currentChatId == null && _chatSessions.isNotEmpty) {
        // .first obtiene el chat más reciente porque en tu consulta a Firebase 
        // le pusiste 'orderBy('createdAt', descending: true)'
        loadChatSession(_chatSessions.first.id);
      }
    } catch (e) {
      debugPrint("Error obteniendo chats: $e");
    }
  }

  String get _systemInstruction =>
      'Eres un profesor de matemáticas experto y amigable en una app de graficación.\n'
      'Responde SIEMPRE en el idioma con código: $_currentLanguage.\n'
      'Reglas:\n'
      '1. Explica los conceptos de forma clara, didáctica y conversacional.\n'
      '2. Si tienes que mostrar una fórmula matemática, fracciones, integrales o ecuaciones, SIEMPRE usa el formato LaTeX envuelto en símbolos de dólar. Por ejemplo: \$x^2 + y^2 = r^2\$ o \$\$\\frac{1}{2}\$\$.\n'
      '3. Usa negritas y viñetas para organizar tu texto.\n'
      '4. Si el usuario pide datos o comparaciones, genérale tablas en formato Markdown.';

  // --- 1. Vectorizamos la pregunta usando el SDK OFICIAL (Actualizado 2026) ---
  Future<List<double>> _getEmbedding(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No se encontró GEMINI_API_KEY en el archivo .env');
    }

    // ✅ NUEVO MODELO OFICIAL
    final model = genai.GenerativeModel(
      model: 'gemini-embedding-001', 
      apiKey: apiKey,
    );

    try {
      final content = genai.Content.text(text);
      final result = await model.embedContent(
        content,
        // Recomendado para sistemas RAG: mejora la precisión de la búsqueda
        taskType: genai.TaskType.retrievalQuery, 
      );
      
      return result.embedding.values;
    } catch (e) {
      debugPrint('Error en SDK al vectorizar: $e');
      throw Exception('Error al vectorizar la pregunta');
    }
  }

  // --- 2. Búsqueda Vectorial Matemática (Calculada en el teléfono) ---
  Future<String> _buscarEnLibros(List<double> vectorPregunta) async {
    try {
      // Descargamos los fragmentos de la nube
      final querySnapshot = await _firestore.collection('knowledge_base').get();

      List<Map<String, dynamic>> resultados = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('embedding') && data.containsKey('texto')) {
          
          List<double> docVector = [];
          var rawVector = data['embedding'];
          
          if (rawVector is List) {
            docVector = rawVector.map((e) => (e as num).toDouble()).toList();
          } else {
            docVector = (rawVector as VectorValue).toArray().map((e) => (e as num).toDouble()).toList();
          }

          if (docVector.isNotEmpty) {
             double similitud = _cosineSimilarity(vectorPregunta, docVector);
             
             resultados.add({
               'texto': data['texto'],
               'score': similitud
             });
          }
        }
      }

      // Ordenamos para que los fragmentos más parecidos a la pregunta queden de primeros
      resultados.sort((a, b) => b['score'].compareTo(a['score']));

      // Extraemos los textos de los 3 mejores fragmentos
      String contextoExtraido = "";
      for (int i = 0; i < min(3, resultados.length); i++) {
        contextoExtraido += resultados[i]['texto'] + "\n\n";
      }
      return contextoExtraido.trim();
    } catch (e) {
      debugPrint("Error buscando en la base de datos vectorial: $e");
      return ""; 
    }
  }

  // --- Fórmula Matemática de RAG ---
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<void> sendMessage(String text, {String? currentEquation, String? languageCode}) async {
    if (text.isEmpty) return;

    if (languageCode != null && languageCode.isNotEmpty) {
      _currentLanguage = languageCode;
    }

    _isLoading = true;
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    try {
      // 1. Convertimos la pregunta del usuario en vector
      final vectorPregunta = await _getEmbedding(text);
      
      // 2. Buscamos fragmentos relevantes en Firestore matemáticamente
      final extractoDelLibro = await _buscarEnLibros(vectorPregunta);

      // 3. Construimos el Prompt aumentado (RAG)
      String promptToSend = 
          'El usuario tiene esta pregunta: "$text".\n';
          
      if (extractoDelLibro.isNotEmpty) {
        promptToSend += 
          'Usa EXCLUSIVAMENTE esta teoría extraída de nuestros libros oficiales para responderle de forma precisa y detallada:\n'
          '--- INICIO TEORÍA ---\n$extractoDelLibro\n--- FIN TEORÍA ---\n';
      }

      if (currentEquation != null && currentEquation.isNotEmpty) {
        promptToSend += '\nEl usuario está analizando actualmente la función: f(x) = $currentEquation.';
      }

      _history.add({
        'role': 'user',
        'parts': [
          {'text': promptToSend}
        ],
      });

      final responseText = await _callGeminiAPI();

      _history.add({
        'role': 'model',
        'parts': [
          {'text': responseText}
        ],
      });

      _messages.add(ChatMessage(text: responseText, isUser: false));

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

  Future<void> translateLocalMessage(int index, String targetLanguageCode) async {
    if (index < 0 || index >= _messages.length) return;

    final msg = _messages[index];
    if (msg.isUser || msg.text.isEmpty) return;

    msg.isTranslating = true;
    notifyListeners();

    try {
      final translation = await _translator.translate(msg.text, to: targetLanguageCode);
      msg.text = translation.text;
    } catch (e) {
      debugPrint("Error al traducir localmente: $e");
    } finally {
      msg.isTranslating = false;
      notifyListeners();
    }
  }

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

    // ✅ ESTE MODELO SIGUE VIGENTE Y ES EL MÁS PODEROSO ACTUALMENTE
    const model = 'gemini-3-flash-preview';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction} 
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

  void clearChat() {
    _currentChatId = null;
    _messages.clear();
    _history.clear();
    notifyListeners();
  }
}