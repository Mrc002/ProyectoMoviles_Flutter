import 'dart:io';
import 'dart:convert'; // <--- NUEVO: Para convertir a Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  bool _isPremium = false;
  String _userName = '';
  String _photoUrl = ''; 

  bool get isPremium => _isPremium;
  String get userName => _userName;
  String get photoUrl => _photoUrl; 

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      
      if (user != null && !user.isAnonymous) {
        try {
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            _isPremium = data['isPremium'] ?? false;
            _userName = data['name'] ?? 'Usuario';
            _photoUrl = data['photoUrl'] ?? ''; 
          }
        } catch (e) {
          debugPrint("Error leyendo datos: $e");
        }
      } else {
        _isPremium = false;
        _userName = '';
        _photoUrl = ''; 
      }
      notifyListeners();
    });
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return null; 
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    }
  }

  Future<String?> signInAsGuest() async {
    try {
      _setLoading(true);
      await _auth.signInAnonymously();
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? 'Error';
    }
  }

  Future<String?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      _setLoading(true);
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'name': name,
          'isPremium': false,
          'aiQueriesUsed': 0,
          'photoUrl': '', 
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

  Future<void> updateProfilePicture(String urlOrBase64) async {
    if (_user != null && !_user!.isAnonymous) {
      try {
        await _firestore.collection('users').doc(_user!.uid).update({'photoUrl': urlOrBase64});
        _photoUrl = urlOrBase64;
        notifyListeners();
      } catch (e) {
        debugPrint("Error actualizando foto: $e");
      }
    }
  }

  // --- NUEVA LÓGICA BASE64 (Sin usar Firebase Storage) ---
  Future<void> uploadProfileImage(File imageFile) async {
    if (_user == null || _user!.isAnonymous) return;
    
    try {
      _setLoading(true);
      
      // 1. Leemos la imagen física como bytes
      final bytes = await imageFile.readAsBytes();
      
      // 2. La convertimos a un texto largo (Base64)
      final base64String = base64Encode(bytes);

      // 3. Guardamos ese texto directamente en tu Firestore
      await updateProfilePicture(base64String);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint("Error convirtiendo imagen: $e");
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