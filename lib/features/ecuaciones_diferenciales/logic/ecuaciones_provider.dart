import 'package:flutter/material.dart';
// Descomenta esta línea cuando tengas Firebase configurado en tu proyecto
// import 'package:cloud_firestore/cloud_firestore.dart';

class EcuacionesProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _temasCargados = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get temasCargados => _temasCargados;

  Future<void> fetchTemasPorCategoria(String categoria) async {
    _isLoading = true;
    _temasCargados = [];
    notifyListeners(); // Avisamos a la UI que estamos cargando

    try {
      /* // LÓGICA REAL PARA FIREBASE (La usaremos cuando subamos los datos)
      final snapshot = await FirebaseFirestore.instance
          .collection('Temas_Ecuaciones')
          .where('categoria', isEqualTo: categoria)
          .get();
          
      _temasCargados = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      */

      // DATOS SIMULADOS (Mock) para que puedas ver el diseño ahora mismo
      await Future.delayed(const Duration(milliseconds: 800)); // Simulamos el internet
      
      if (categoria == 'EDOs') {
        _temasCargados = [
          {'titulo': 'Ecuaciones de Variables Separables', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Exactas y Factor Integrante', 'bibliografia': 'Shepley L. Ross, Cap. 2'},
          {'titulo': 'Ecuaciones Lineales de Orden Superior', 'bibliografia': 'Shepley L. Ross, Cap. 4'},
          {'titulo': 'Transformada de Laplace', 'bibliografia': 'Shepley L. Ross, Cap. 6'},
        ];
      } else if (categoria == 'EDPs') {
        _temasCargados = [
          {'titulo': 'La Ecuación de Onda', 'bibliografia': 'Hans F. Weinberger, Cap. 2'},
          {'titulo': 'La Ecuación del Calor', 'bibliografia': 'Hans F. Weinberger, Cap. 3'},
          {'titulo': 'Separación de Variables', 'bibliografia': 'Hans F. Weinberger, Cap. 5'},
        ];
      }
      // Puedes agregar los de 'Sistemas' y 'Frontera' aquí si deseas previsualizarlos

    } catch (e) {
      debugPrint("Error al cargar temas: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la UI que ya terminamos
    }
  }
}