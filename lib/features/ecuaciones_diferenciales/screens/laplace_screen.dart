import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LaplaceScreen extends StatefulWidget {
  const LaplaceScreen({Key? key}) : super(key: key);

  @override
  State<LaplaceScreen> createState() => _LaplaceScreenState();
}

class _LaplaceScreenState extends State<LaplaceScreen> {
  final TextEditingController _funcionController = TextEditingController();
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _funcionController.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_funcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una función f(t).')),
      );
      return;
    }
    setState(() {
      _mostrarResultado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFE67E3A); // Naranja asignado a Laplace

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformada de Laplace'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFFDF7F2),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Definición integral:', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.transparent : primaryColor.withOpacity(0.3)),
                  ),
                  child: Math.tex(
                    r'\mathcal{L}\{f(t)\} = \int_{0}^{\infty} e^{-st} f(t) dt',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('Función f(t):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _funcionController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. t^2 + sin(t)',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.transform, color: Colors.white),
                  label: const Text('Calcular L{f(t)}', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (_mostrarResultado) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text('Resultado Analítico:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : primaryColor)),
                const SizedBox(height: 15),
                _buildPaso(context, 'Transformada F(s)', r'F(s) = \mathcal{L}\{' + _funcionController.text + r'\}', isDark, primaryColor),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaso(BuildContext context, String titulo, String formulaLatex, bool isDark, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C3350) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Math.tex(
              formulaLatex,
              textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : color),
            ),
          ),
        ],
      ),
    );
  }
}