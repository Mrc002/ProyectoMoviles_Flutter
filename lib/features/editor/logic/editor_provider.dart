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
  Offset? _startFocalPoint;

  String get equation => _equation;
  bool get isValid => _isValid;
  List<FlSpot> get points => _points;
  bool get is3DMode => _is3DMode;

  EditorProvider() {
    _validateEquation();
    _calculatePoints();
  }

  // --- LÓGICA DE GESTOS (ZOOM Y PAN) ---
  void startGesture(ScaleStartDetails details) {
    _baseMinX = minX;
    _baseMaxX = maxX;
    _baseMinY = minY;
    _baseMaxY = maxY;
    _startFocalPoint = details.localFocalPoint;
  }

  void updateGesture(ScaleUpdateDetails details, Size size) {
    if (_startFocalPoint == null) return;

    double newWidth = (_baseMaxX - _baseMinX) / details.scale;
    double newHeight = (_baseMaxY - _baseMinY) / details.scale;

    double dxPixels = details.localFocalPoint.dx - _startFocalPoint!.dx;
    double dyPixels = details.localFocalPoint.dy - _startFocalPoint!.dy;

    double dxMath = -dxPixels * (newWidth / size.width);
    double dyMath = dyPixels * (newHeight / size.height); 

    double baseCenterX = (_baseMinX + _baseMaxX) / 2;
    double baseCenterY = (_baseMinY + _baseMaxY) / 2;

    double newCenterX = baseCenterX + dxMath;
    double newCenterY = baseCenterY + dyMath;

    minX = newCenterX - newWidth / 2;
    maxX = newCenterX + newWidth / 2;
    minY = newCenterY - newHeight / 2;
    maxY = newCenterY + newHeight / 2;

    _calculatePoints();
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
      if (_equation.trim().isEmpty) {
        _isValid = false;
        return;
      }
      final parser = GrammarParser();
      parser.parse(_equation);
      _isValid = true;
    } catch (e) {
      _isValid = false;
    }
  }

  void _calculatePoints() {
    try {
      if (_is3DMode) return;

      final parser = GrammarParser();
      final expression = parser.parse(_equation);
      
      // CORRECCIÓN 1: Creamos el modelo de contexto
      ContextModel cm = ContextModel();
      
      // CORRECCIÓN 2: Pasamos el 'cm' al constructor y usamos 'final' (no const)
      final evaluator = RealEvaluator(cm);

      List<FlSpot> tempPoints = [];
      double range = maxX - minX;
      double step = range / 300; 

      double start = minX - range; 
      double end = maxX + range;

      for (double x = start; x <= end; x += step) {
        // Al actualizar 'cm' aquí, el 'evaluator' lo reconoce automáticamente
        cm.bindVariable(Variable('x'), Number(x));
        
        // CORRECCIÓN 3: Usamos .evaluate(expression) y convertimos a double
        // (La librería devuelve 'num', por eso el .toDouble() es importante)
        double y = evaluator.evaluate(expression).toDouble();
        
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