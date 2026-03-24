import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ExactasScreen extends StatefulWidget {
  const ExactasScreen({Key? key}) : super(key: key);

  @override
  State<ExactasScreen> createState() => _ExactasScreenState();
}

class _ExactasScreenState extends State<ExactasScreen> {
  final TextEditingController _mxController = TextEditingController();
  final TextEditingController _nyController = TextEditingController();
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _mxController.dispose();
    _nyController.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_mxController.text.isEmpty || _nyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa M(x,y) y N(x,y).')),
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
    final primaryColor = const Color(0xFF5B9BD5); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecuaciones Exactas'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INSTRUCCIONES Y FÓRMULA ---
              Text(
                'Lleva tu ecuación a la forma diferencial:',
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.blue.shade100),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Math.tex(
                    r'M(x,y)dx + N(x,y)dy = 0',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- CAMPOS DE ENTRADA ---
              Text('1. Ingresa M(x,y):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _mxController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2xy',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Ingresa N(x,y):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _nyController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. x^2 - 1',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 30),

              // --- BOTÓN DE CALCULAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.fact_check, color: Colors.white),
                  label: const Text('Verificar si es exacta', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- RESULTADOS (Mockup visual) ---
              if (_mostrarResultado) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text('Procedimiento analítico:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(context, '1. Criterio de exactitud', r'\frac{\partial M}{\partial y} = \frac{\partial N}{\partial x}', isDark),
                _buildPaso(context, '2. Integrar M(x,y) respecto a x', r'f(x,y) = \int (' + _mxController.text + r') dx + g(y)', isDark),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaso(BuildContext context, String titulo, String formulaLatex, bool isDark) {
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
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Math.tex(
              formulaLatex,
              textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }
}