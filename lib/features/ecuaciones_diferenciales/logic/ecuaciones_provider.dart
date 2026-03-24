import 'package:flutter/material.dart';

class EcuacionesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _temasCargados = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get temasCargados => _temasCargados;
  bool get isLoading => _isLoading;

  Future<void> fetchTemasPorCategoria(String categoria) async {
    _isLoading = true;
    notifyListeners();

    // Simula el tiempo de carga de una base de datos (puedes conectarlo a Firestore después)
    await Future.delayed(const Duration(milliseconds: 600));

    switch (categoria) {
      case 'EDOs':
        _temasCargados = [
          {'titulo': 'Ecuaciones de Variables Separables', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Exactas y Factores Integrantes', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Lineales de Primer Orden', 'bibliografia': 'Edwards & Penney, Cap. 1'},
          {'titulo': 'Ecuación de Bernoulli', 'bibliografia': 'Irineo Peral Alonso, Cap. 1'},
        ];
        break;
      case 'Segundo Orden':
        _temasCargados = [
          {'titulo': 'Ecuaciones Lineales Homogéneas', 'bibliografia': 'Shepley L. Ross, Cap. 4'},
          {'titulo': 'Coeficientes Constantes', 'bibliografia': 'Edwards & Penney, Cap. 3'},
          {'titulo': 'Método de Coeficientes Indeterminados', 'bibliografia': 'Shepley L. Ross, Cap. 4'},
          {'titulo': 'Variación de Parámetros', 'bibliografia': 'Irineo Peral Alonso, Cap. 2'},
        ];
        break;
      case 'Laplace':
        _temasCargados = [
          {'titulo': 'Definición de Transformada de Laplace', 'bibliografia': 'Edwards & Penney, Cap. 7'},
          {'titulo': 'Transformadas Inversas', 'bibliografia': 'Shepley L. Ross, Cap. 7'},
          {'titulo': 'Función Escalón Unitario (Heaviside)', 'bibliografia': 'Edwards & Penney, Cap. 7'},
          {'titulo': 'Teoremas de Traslación', 'bibliografia': 'Irineo Peral Alonso, Cap. 4'},
        ];
        break;
      case 'Sistemas':
        _temasCargados = [
          {'titulo': 'Sistemas Lineales de Primer Orden', 'bibliografia': 'Edwards & Penney, Cap. 5'},
          {'titulo': 'Método de Valores Propios', 'bibliografia': 'Shepley L. Ross, Cap. 11'},
          {'titulo': 'Plano de Fase y Estabilidad', 'bibliografia': 'Edwards & Penney, Cap. 6'},
        ];
        break;
      case 'Frontera':
        _temasCargados = [
          {'titulo': 'Soluciones en Series de Potencias', 'bibliografia': 'Shepley L. Ross, Cap. 6'},
          {'titulo': 'Ecuación de Bessel', 'bibliografia': 'Edwards & Penney, Cap. 8'},
          {'titulo': 'Ecuación de Legendre', 'bibliografia': 'Irineo Peral Alonso, Cap. 5'},
        ];
        break;
      case 'EDPs':
        _temasCargados = [
          {'titulo': 'Separación de Variables', 'bibliografia': 'Hans F. Weinberger, Cap. 2'},
          {'titulo': 'Ecuación de Calor', 'bibliografia': 'Edwards & Penney, Cap. 9'},
          {'titulo': 'Ecuación de Onda', 'bibliografia': 'Hans F. Weinberger, Cap. 3'},
        ];
        break;
      default:
        _temasCargados = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}