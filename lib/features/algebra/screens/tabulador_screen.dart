import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class TabuladorScreen extends StatefulWidget {
  const TabuladorScreen({super.key});

  @override
  State<TabuladorScreen> createState() => _TabuladorScreenState();
}

class _TabuladorScreenState extends State<TabuladorScreen> {
  final _funcionController = TextEditingController(text: 'x^2 - 4');
  final _x0Controller = TextEditingController(text: '-5');
  final _xfController = TextEditingController(text: '5');
  final _pasoController = TextEditingController(text: '1');

  List<Map<String, dynamic>> _tabla = [];
  String _mensajeError = '';

  @override
  void dispose() {
    _funcionController.dispose(); _x0Controller.dispose(); _xfController.dispose(); _pasoController.dispose();
    super.dispose();
  }

  void _tabular() {
    setState(() { _tabla.clear(); _mensajeError = ''; });

    String funcString = _funcionController.text;
    double x0 = double.tryParse(_x0Controller.text) ?? 0;
    double xf = double.tryParse(_xfController.text) ?? 0;
    double paso = double.tryParse(_pasoController.text) ?? 1;

    if (paso <= 0) {
      setState(() => _mensajeError = 'El paso de incremento debe ser mayor a 0.');
      return;
    }
    if (x0 > xf) {
      setState(() => _mensajeError = 'El valor inicial no puede ser mayor al final.');
      return;
    }

    try {
      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(funcString);
      ContextModel cm = ContextModel();

      double currentX = x0;
      int limiter = 0;
      
      while (currentX <= xf + 0.0001 && limiter < 1000) { 
        cm.bindVariable(Variable('x'), Number(currentX));
        double fDeX = exp.evaluate(EvaluationType.REAL, cm);
        
        _tabla.add({'x': currentX, 'fx': fDeX});
        currentX += paso;
        limiter++;
      }
    } catch (e) {
      setState(() => _mensajeError = 'Error de sintaxis en la función. Usa "x" como variable.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF009688);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        title: const Text('Tabulador de Funciones'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(controller: _funcionController, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Función f(x)', prefixIcon: const Icon(Icons.functions), filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _x0Controller, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'x inicial', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _xfController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'x final', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _pasoController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black87), decoration: InputDecoration(labelText: 'Paso', filled: true, fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _tabular, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Generar Tabla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_mensajeError.isNotEmpty) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)), child: Text(_mensajeError, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
            
            if (_tabla.isNotEmpty) ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1C3350) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.1)),
                      columnSpacing: 60,
                      columns: const [
                        DataColumn(label: Text('x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), 
                        DataColumn(label: Text('f(x)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF009688))))
                      ],
                      rows: _tabla.map((row) => DataRow(cells: [
                        DataCell(Text((row['x'] as double).toStringAsFixed(2))), 
                        DataCell(Text((row['fx'] as double).toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold)))
                      ])).toList(),
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}