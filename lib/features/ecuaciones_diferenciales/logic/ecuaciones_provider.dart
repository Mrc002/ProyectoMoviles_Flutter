import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class EcuacionesProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _temasCargados = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get temasCargados => _temasCargados;

  Future<void> fetchTemasPorCategoria(String categoria) async {
    _isLoading = true;
    _temasCargados = [];
    notifyListeners(); 

    try {
      // Simulamos la carga desde Internet
      await Future.delayed(const Duration(milliseconds: 600)); 
      
      if (categoria == 'EDOs') {
        _temasCargados = [
          {'titulo': 'Ecuaciones de Variables Separables', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Exactas y Factor Integrante', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Lineales de Orden Superior', 'bibliografia': 'Shepley L. Ross, Cap. 4'},
          {'titulo': 'Transformada de Laplace', 'bibliografia': 'Shepley L. Ross, Cap. 6'},
        ];
      } 
      // --- NUEVO: Datos para Sistemas y Series ---
      else if (categoria == 'Sistemas') {
        _temasCargados = [
          {'titulo': 'Sistemas Lineales y Valores Propios', 'bibliografia': 'Edwards & Penney, Cap. 5'},
          {'titulo': 'Matrices Fundamentales', 'bibliografia': 'Edwards & Penney, Cap. 5'},
          {'titulo': 'Series de Fourier y Convergencia', 'bibliografia': 'Edwards & Penney, Cap. 9'},
        ];
      } 
      // --- NUEVO: Datos para Valores en la Frontera ---
      else if (categoria == 'Frontera') {
        _temasCargados = [
          {'titulo': 'Problemas de Valores en la Frontera', 'bibliografia': 'Edwards & Penney, Cap. 10'},
          {'titulo': 'Teoría de Sturm-Liouville', 'bibliografia': 'Edwards & Penney, Cap. 10'},
        ];
      } 
      else if (categoria == 'EDPs') {
        _temasCargados = [
          {'titulo': 'La Ecuación de Onda', 'bibliografia': 'Hans F. Weinberger, Cap. 2'},
          {'titulo': 'La Ecuación del Calor', 'bibliografia': 'Hans F. Weinberger, Cap. 3'},
          {'titulo': 'Separación de Variables', 'bibliografia': 'Hans F. Weinberger, Cap. 5'},
        ];
      }

    } catch (e) {
      debugPrint("Error al cargar temas: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}