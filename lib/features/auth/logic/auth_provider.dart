import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // <--- BD
  
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  bool _isPremium = false;
  String _userName = '';

  bool get isPremium => _isPremium;
  String get userName => _userName;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      
      // Si el usuario se loguea y NO es invitado, buscamos sus datos en Firestore
      if (user != null && !user.isAnonymous) {
        try {
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            _isPremium = data['isPremium'] ?? false;
            _userName = data['name'] ?? 'Usuario';
          }
        } catch (e) {
          debugPrint("Error leyendo datos del usuario: $e");
        }
      } else {
        // Si es invitado o se desloguea, limpiamos los datos
        _isPremium = false;
        _userName = '';
      }
      notifyListeners();
    });
  }

  // Retorna un String con el error, o null si fue exitoso
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return null; 
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message; // Retornamos el error para mostrarlo en la UI
    }
  }

  // --- NUEVO: Iniciar sesión como Invitado ---
  Future<String?> signInAsGuest() async {
    try {
      _setLoading(true);
      await _auth.signInAnonymously();
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Error al entrar como invitado';
    }
  }

  // Registrar y crear documento en Firestore (Para lo Premium)
  Future<String?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      _setLoading(true);
      // 1. Crear usuario en Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Guardar en Firestore la información de negocio
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'name': name,
          'isPremium': false, // <--- POR DEFECTO TODOS SON GRATIS
          'aiQueriesUsed': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}