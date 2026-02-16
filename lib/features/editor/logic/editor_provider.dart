import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:fl_chart/fl_chart.dart';

class EditorProvider extends ChangeNotifier {
  String _equation = 'x^2';
  bool _isValid = true;
  List<FlSpot> _points = [];
  bool _is3DMode = false;

  // --- CÁMARA DINÁMICA (ESTADO DEL ZOOM Y POSICIÓN) ---
  double minX = -10, maxX = 10;
  double minY = -10, maxY = 10;
  
  // Variables para controlar el gesto de zoom
  double _baseMinX = -10, _baseMaxX = 10;
  double _baseMinY = -10, _baseMaxY = 10;
  Offset? _startFocalPoint; // Para rastrear el desplazamiento desde el inicio

  String get equation => _equation;
  bool get isValid => _isValid;
  List<FlSpot> get points => _points;
  bool get is3DMode => _is3DMode;

  EditorProvider() {
    _calculatePoints();
  }

  // --- LÓGICA DE GESTOS (ZOOM Y PAN) ---
  
  // 1. Iniciar el gesto (guardamos cómo estaba la pantalla antes de mover)
  void startGesture(ScaleStartDetails details) {
    _baseMinX = minX;
    _baseMaxX = maxX;
    _baseMinY = minY;
    _baseMaxY = maxY;
    _startFocalPoint = details.localFocalPoint;
  }

  // 2. Actualizar el gesto (Zoom y Mover al mismo tiempo)
  void updateGesture(ScaleUpdateDetails details, Size size) {
    if (_startFocalPoint == null) return;

    // A. ZOOM: Calculamos el nuevo tamaño del viewport basado en la escala acumulada
    // Usamos las variables _base para evitar errores de redondeo acumulativos
    double newWidth = (_baseMaxX - _baseMinX) / details.scale;
    double newHeight = (_baseMaxY - _baseMinY) / details.scale;

    // B. PAN: Calculamos cuánto se ha movido el dedo desde el inicio
    double dxPixels = details.localFocalPoint.dx - _startFocalPoint!.dx;
    double dyPixels = details.localFocalPoint.dy - _startFocalPoint!.dy;

    // Convertimos ese movimiento de píxeles a unidades matemáticas
    // Nota: Usamos 'newWidth' porque el gráfico ya está escalado
    double dxMath = -dxPixels * (newWidth / size.width);
    double dyMath = dyPixels * (newHeight / size.height); 
    // dyMath es positivo porque en gráficas matemáticas Y sube, pero en pantalla Y baja.
    // Al arrastrar hacia abajo (+dyPixels), queremos ver la parte de arriba de la gráfica (+Y),
    // por lo que movemos el viewport hacia arriba.

    // C. APLICAR: Calculamos el nuevo centro
    double baseCenterX = (_baseMinX + _baseMaxX) / 2;
    double baseCenterY = (_baseMinY + _baseMaxY) / 2;

    double newCenterX = baseCenterX + dxMath;
    double newCenterY = baseCenterY + dyMath;

    minX = newCenterX - newWidth / 2;
    maxX = newCenterX + newWidth / 2;
    minY = newCenterY - newHeight / 2;
    maxY = newCenterY + newHeight / 2;

    _calculatePoints(); // Recalculamos la gráfica para la nueva vista
    notifyListeners();
  }

  // --- LÓGICA DE CÁLCULO ---

  void toggleMode() {
    _is3DMode = !_is3DMode;
    notifyListeners();
  }

  void updateEquation(String input) {
    _equation = input;
    _validateEquation();
    if (_isValid) _calculatePoints();
    notifyListeners();
  }

  void _validateEquation() {
    try {
      if (_equation.isEmpty) {
        _isValid = false;
        return;
      }
      Parser p = Parser();
      p.parse(_equation);
      _isValid = true;
    } catch (e) {
      _isValid = false;
    }
  }

  void _calculatePoints() {
    try {
      if (_is3DMode) return; // Si es 3D, no calculamos puntos 2D

      Parser p = Parser();
      Expression exp = p.parse(_equation);
      ContextModel cm = ContextModel();
      List<FlSpot> tempPoints = [];

      // DENSIDAD DINÁMICA:
      // Calculamos cuántos puntos necesitamos para que se vea suave en el zoom actual
      double range = maxX - minX;
      double step = range / 300; // Siempre generamos ~300 puntos en pantalla

      // Generamos un poco más allá de la pantalla (buffer) para que no se corte al arrastrar
      double start = minX - range; 
      double end = maxX + range;

      for (double x = start; x <= end; x += step) {
        cm.bindVariable(Variable('x'), Number(x));
        double y = exp.evaluate(EvaluationType.REAL, cm);
        
        // Solo agregamos puntos que sean números válidos (no infinitos)
        if (y.isFinite && !y.isNaN) {
          tempPoints.add(FlSpot(x, y));
        }
      }
      _points = tempPoints;
    } catch (e) {
      _points = [];
    }
  }
}