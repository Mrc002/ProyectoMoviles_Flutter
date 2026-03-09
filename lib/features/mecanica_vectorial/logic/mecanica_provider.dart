//Toda la logica de la sección de mecánica vectorial.

import 'package:flutter/material.dart';
//import 'dart:math';

// MODELOS BÁSICOS PARA LA FASE 1 
class DclVector {
  String id;
  double magnitud; // Ej. 500 N
  double anguloGrados; // 0 a 360 
  bool esSaliente; // Tensión o Compresión 

  DclVector({
    required this.id,
    this.magnitud = 0.0,
    this.anguloGrados = 0.0,
    this.esSaliente = true,
  });
}

class MecanicaProvider extends ChangeNotifier {
  // Estado del lienzo
  final List<DclVector> _vectores = [];
  
  List<DclVector> get vectores => _vectores;

  // Verifica si el canvas tiene elementos
  bool get isCanvasEmpty => _vectores.isEmpty;

  // Agregar un nuevo vector
  void agregarVectorBase() {
    _vectores.add(
      DclVector(
        id: 'V_${_vectores.length + 1}',
        magnitud: 100.0, // Valor por defecto
        anguloGrados: 45.0, // Ángulo por defecto
      )
    );
    notifyListeners(); // Avisa a la UI que debe redibujarse
  }

  // Actualizar ángulo (Para el drag and drop de 15 en 15 grados) [cite: 43]
  void actualizarAngulo(String id, double nuevosGrados) {
    final index = _vectores.indexWhere((v) => v.id == id);
    if (index != -1) {
      // Aplicar snapping magnético de 15 grados 
      double anguloSnapping = (nuevosGrados / 15).round() * 15.0;
      _vectores[index].anguloGrados = anguloSnapping;
      notifyListeners();
    }
  }

  // Aquí en el futuro irán tus sumatorias de fuerzas
  // 1. Incógnitas identificadas
  String get incognitasIdentificadas {
    if (isCanvasEmpty) return "Esperando diagrama...";
    return "Reacciones en el nodo origen (Rx, Ry)."; 
  }

  // 2. Ecuaciones de Equilibrio (Sumatorias)
  String get ecuacionesEquilibrio {
    if (isCanvasEmpty) return "ΣFx = 0 \nΣFy = 0";
    // Aquí iría tu lógica real de suma de vectores
    return "ΣFx = 100 cos(45°) - Rx = 0 \nΣFy = 100 sin(45°) - Ry = 0";
  }

  // 3. Resultados exactos sin IA
  String get resultadoFinal {
    if (isCanvasEmpty) return "Dibuja vectores para calcular.";
    // Resultado determinista
    return "Rx = 70.71 N \nRy = 70.71 N";
  }
}