import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LinealesScreen extends StatefulWidget {
  const LinealesScreen({Key? key}) : super(key: key);

  @override
  State<LinealesScreen> createState() => _LinealesScreenState();
}

class _LinealesScreenState extends State<LinealesScreen> {
  final TextEditingController _pxController = TextEditingController();
  final TextEditingController _qxController = TextEditingController();
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _pxController.dispose();
    _qxController.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_pxController.text.isEmpty || _qxController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa P(x) y Q(x).')),
      );
      return;
    }
    
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    setState(() {
      _mostrarResultado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5); // Azul del módulo EDOs

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDO Lineal (Factor Integrante)'),
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
              // --- INSTRUCCIONES Y FÓRMULA ESTÁNDAR ---
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
                    r'\frac{dy}{dx} + P(x)y = Q(x)',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- CAMPOS DE ENTRADA ---
              Text('1. Ingresa P(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _pxController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2/x',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('2. Ingresa Q(x):', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _qxController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. x^2',
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

              // --- RESULTADOS PASO A PASO ---
              if (_mostrarResultado) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text('Procedimiento analítico:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(
                  context, 
                  '1. Calcular Factor Integrante μ(x)', 
                  r'\mu(x) = e^{\int (' + _pxController.text + r') dx}', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  '2. Multiplicar toda la EDO por μ(x)', 
                  r'\frac{d}{dx}[\mu(x) y] = \mu(x) \cdot (' + _qxController.text + r')', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  '3. Integrar ambos lados y despejar y', 
                  r'y = \frac{1}{\mu(x)} \left[ \int \mu(x) (' + _qxController.text + r') dx + C \right]', 
                  isDark
                ),
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