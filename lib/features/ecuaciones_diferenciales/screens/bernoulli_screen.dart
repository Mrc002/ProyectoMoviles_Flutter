import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class BernoulliScreen extends StatefulWidget {
  const BernoulliScreen({Key? key}) : super(key: key);

  @override
  State<BernoulliScreen> createState() => _BernoulliScreenState();
}

class _BernoulliScreenState extends State<BernoulliScreen> {
  final TextEditingController _pxController = TextEditingController();
  final TextEditingController _qxController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _pxController.dispose();
    _qxController.dispose();
    _nController.dispose();
    super.dispose();
  }

  void _calcular() {
    if (_pxController.text.isEmpty || _qxController.text.isEmpty || _nController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa P(x), Q(x) y el valor de n.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus();
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
        title: const Text('Ecuación de Bernoulli'),
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
              Text(
                'Lleva tu ecuación a la forma de Bernoulli:',
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
                    r'\frac{dy}{dx} + P(x)y = Q(x)y^n',
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
                  hintText: 'Ej. 1/x',
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
                  hintText: 'Ej. x',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 20),

              Text('3. Ingresa la potencia n:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              TextField(
                controller: _nController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej. 2',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF234060) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.superscript),
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
                  label: const Text('Transformar y Resolver', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                  '1. Sustitución para reducir a lineal', 
                  r'u = y^{1 - (' + _nController.text + r')}', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  '2. EDO Lineal resultante en términos de u', 
                  r'\frac{du}{dx} + (1 - ' + _nController.text + r')(' + _pxController.text + r')u = (1 - ' + _nController.text + r')(' + _qxController.text + r')', 
                  isDark
                ),
                _buildPaso(
                  context, 
                  '3. Regresar a la variable original y', 
                  r'y = u^{\frac{1}{1 - ' + _nController.text + r'}}', 
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