import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class SistemasSeriesScreen extends StatefulWidget {
  const SistemasSeriesScreen({super.key});

  @override
  State<SistemasSeriesScreen> createState() => _SistemasSeriesScreenState();
}

class _SistemasSeriesScreenState extends State<SistemasSeriesScreen> {
  // Controladores para la matriz 2x2
  final TextEditingController _a11Controller = TextEditingController();
  final TextEditingController _a12Controller = TextEditingController();
  final TextEditingController _a21Controller = TextEditingController();
  final TextEditingController _a22Controller = TextEditingController();
  
  final FocusNode _a11Focus = FocusNode();
  final FocusNode _a12Focus = FocusNode();
  final FocusNode _a21Focus = FocusNode();
  final FocusNode _a22Focus = FocusNode();
  
  bool _mostrarResultado = false;

  @override
  void dispose() {
    _a11Controller.dispose();
    _a12Controller.dispose();
    _a21Controller.dispose();
    _a22Controller.dispose();
    _a11Focus.dispose();
    _a12Focus.dispose();
    _a21Focus.dispose();
    _a22Focus.dispose();
    super.dispose();
  }

  void _insertarSimbolo(String simbolo) {
    TextEditingController? activeController;
    if (_a11Focus.hasFocus) activeController = _a11Controller;
    if (_a12Focus.hasFocus) activeController = _a12Controller;
    if (_a21Focus.hasFocus) activeController = _a21Controller;
    if (_a22Focus.hasFocus) activeController = _a22Controller;

    if (activeController != null) {
      final text = activeController.text;
      final selection = activeController.selection;
      
      final start = selection.start >= 0 ? selection.start : text.length;
      final end = selection.end >= 0 ? selection.end : text.length;

      final newText = text.replaceRange(start, end, simbolo);
      activeController.text = newText;

      int offset = start + simbolo.length;
      if (simbolo.endsWith('()') || simbolo.endsWith('{}')) offset -= 1; 
      if (simbolo == r'\frac{}{}') offset -= 3; 
      
      activeController.selection = TextSelection.collapsed(offset: offset);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere seleccionar una caja de texto para insertar el símbolo.')),
      );
    }
  }

  void _calcular() {
    if (_a11Controller.text.isEmpty || _a12Controller.text.isEmpty || 
        _a21Controller.text.isEmpty || _a22Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Es necesario ingresar los 4 componentes de la matriz A.')),
      );
      return;
    }
    
    FocusScope.of(context).unfocus(); 
    setState(() {
      _mostrarResultado = true;
    });
  }

  void _abrirTutorIA(BuildContext context, Color colorTema) {
    final a11 = _a11Controller.text.isNotEmpty ? _a11Controller.text : "0";
    final a12 = _a12Controller.text.isNotEmpty ? _a12Controller.text : "0";
    final a21 = _a21Controller.text.isNotEmpty ? _a21Controller.text : "0";
    final a22 = _a22Controller.text.isNotEmpty ? _a22Controller.text : "0";

    final contextoDinamico = "El usuario se encuentra en la Calculadora de Sistemas de Ecuaciones Diferenciales Lineales (2x2). "
        "El sistema a resolver es X' = AX, donde la matriz A es: [[$a11, $a12], [$a21, $a22]]. "
        "La instrucción operativa es actuar como un tutor matemático objetivo. Si se requiere asistencia, "
        "se debe guiar paso a paso en el cálculo del polinomio característico det(A - \\lambda I) = 0, "
        "la obtención de los eigenvalores (valores propios) y los eigenvectores (vectores propios) correspondientes. "
        "Es obligatorio emplear formato LaTeX con \$\$ para las expresiones matemáticas y matrices.";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EdChatSheet(
        moduleName: 'Tutor: Sistemas de EDOs',
        contextoDatos: contextoDinamico,
        colorTema: colorTema,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B9BD5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistemas de EDOs (2x2)'),
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
                'Definición del sistema lineal matricial:',
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
                    r'X^\prime = \begin{pmatrix} a_{11} & a_{12} \\ a_{21} & a_{22} \end{pmatrix} X',
                    textStyle: TextStyle(fontSize: 22, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text('Componentes de la Matriz A:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 15),
              
              // Constructor visual de la matriz 2x2
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildMatrixField('a11', _a11Controller, _a11Focus, isDark)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildMatrixField('a12', _a12Controller, _a12Focus, isDark)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildMatrixField('a21', _a21Controller, _a21Focus, isDark)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildMatrixField('a22', _a22Controller, _a22Focus, isDark)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              _buildTecladoMatematico(isDark, primaryColor),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.grid_4x4, color: Colors.white),
                  label: const Text('Calcular Determinante', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                Text('Planteamiento de valores propios:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900])),
                const SizedBox(height: 15),
                _buildPaso(
                  context, 
                  'Ecuación det(A - \u03BBI) = 0', 
                  r'\det \begin{pmatrix} ' + _a11Controller.text + r'-\lambda & ' + _a12Controller.text + r' \\ ' + _a21Controller.text + r' & ' + _a22Controller.text + r'-\lambda \end{pmatrix} = 0', 
                  isDark
                ),
                
                const SizedBox(height: 10),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _abrirTutorIA(context, primaryColor),
                    icon: const Icon(Icons.psychology),
                    label: const Text('Resolver polinomio e eigenvectores con IA'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.amber : Colors.blue[900],
                      side: BorderSide(color: isDark ? Colors.amber : Colors.blue.shade900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                ),
                const SizedBox(height: 80), 
              ]
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirTutorIA(context, primaryColor),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text('Tutor IA', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMatrixField(String hint, TextEditingController controller, FocusNode focus, bool isDark) {
    return TextField(
      controller: controller,
      focusNode: focus,
      textAlign: TextAlign.center,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF234060) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildTecladoMatematico(bool isDark, Color primaryColor) {
    final Map<String, String> botones = {
      '-': '-', '+': '+', '\\frac{x}{y}': r'\frac{}{}', 
      '\\sqrt{x}': '\\sqrt{}', 't': 't', 'e^t': 'e^{}', 
      '\\lambda': '\\lambda', '\\sin': '\\sin()', '\\cos': '\\cos()'
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: botones.entries.map((entrada) {
          return InkWell(
            onTap: () => _insertarSimbolo(entrada.value),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF234060) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Math.tex(
                entrada.key, 
                textStyle: TextStyle(
                  fontSize: 16, 
                  color: isDark ? Colors.amber : Colors.blue[900]
                )
              ),
            ),
          );
        }).toList(),
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
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Math.tex(
                formulaLatex,
                textStyle: TextStyle(fontSize: 18, color: isDark ? Colors.amber : Colors.blue[900]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}