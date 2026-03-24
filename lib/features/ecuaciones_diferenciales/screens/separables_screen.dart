import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SeparablesScreen extends StatefulWidget {
  const SeparablesScreen({Key? key}) : super(key: key);

  @override
  State<SeparablesScreen> createState() => _SeparablesScreenState();
}

class _SeparablesScreenState extends State<SeparablesScreen> {
  final TextEditingController _fxController = TextEditingController();
  final TextEditingController _gyController = TextEditingController();
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _fxController.dispose();
    _gyController.dispose();
    super.dispose();
  }

  void _calcular() {
    // Validar que no estén vacíos
    if (_fxController.text.isEmpty || _gyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa ambas funciones.')),
      );
      return;
    }
    
    // Aquí después conectaremos tu lógica de solución o la API de Gemini
    setState(() {
      _mostrarResultado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5); // Azul EDOs

    return Scaffold(
      appBar: AppBar(
        title: const Text('Variables Separables'),
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
                'Lleva tu ecuación a la forma estándar:',
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
                    r'\frac{dy}{dx} = f(x) \cdot g(y)',
                    textStyle: TextStyle(fontSize: 24, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- CAMPOS DE ENTRADA ---
              Text('1. Ingresa f(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _fxController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2x',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Ingresa g(y):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _gyController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. y^2',
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
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text('Resolver paso a paso', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                _buildPaso(context, '1. Separar variables', r'\frac{dy}{' + _gyController.text + r'} = (' + _fxController.text + r') dx', isDark),
                _buildPaso(context, '2. Integrar ambos lados', r'\int \frac{dy}{' + _gyController.text + r'} = \int (' + _fxController.text + r') dx + C', isDark),
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