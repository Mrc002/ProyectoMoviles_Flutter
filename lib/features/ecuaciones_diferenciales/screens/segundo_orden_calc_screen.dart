import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart';

class SegundoOrdenCalcScreen extends StatelessWidget {
  const SegundoOrdenCalcScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7C6BBD); // Morado para 2do Orden

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Solvers de 2do Orden'),
          backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.functions), text: "Homogénea y PVI"),
              Tab(icon: Icon(Icons.auto_awesome), text: "No Homogénea (IA)"),
            ],
          ),
        ),
        body: Container(
          color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
          child: TabBarView(
            children: [
              _HomogeneaTab(primaryColor: primaryColor, isDark: isDark),
              _NoHomogeneaTab(primaryColor: primaryColor, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// PESTAÑA 1: HOMOGÉNEA Y PROBLEMA DE VALOR INICIAL (PVI)
// =====================================================================
class _HomogeneaTab extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _HomogeneaTab({required this.primaryColor, required this.isDark});

  @override
  State<_HomogeneaTab> createState() => _HomogeneaTabState();
}

class _HomogeneaTabState extends State<_HomogeneaTab> {
  final TextEditingController _aController = TextEditingController(text: '1');
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  
  // Controles PVI
  bool _isPVI = false;
  final TextEditingController _y0Controller = TextEditingController();
  final TextEditingController _yPrime0Controller = TextEditingController();

  bool _mostrarResultado = false;
  String _pasoRaices = '';
  String _solucionGeneral = '';
  String _tipoRaices = '';
  String _solucionParticular = ''; // Para PVI

  void _calcular() {
    double a = double.tryParse(_aController.text) ?? 0;
    double b = double.tryParse(_bController.text) ?? 0;
    double c = double.tryParse(_cController.text) ?? 0;

    if (a == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El coeficiente "a" no puede ser cero.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    double discriminante = (b * b) - (4 * a * c);
    _solucionParticular = '';

    // VARIABLES PARA PVI
    double? C1, C2;
    double y0 = double.tryParse(_y0Controller.text) ?? 0;
    double yp0 = double.tryParse(_yPrime0Controller.text) ?? 0;

    if (discriminante > 0) {
      // CASO 1: Reales y distintas
      double m1 = (-b + sqrt(discriminante)) / (2 * a);
      double m2 = (-b - sqrt(discriminante)) / (2 * a);
      _tipoRaices = 'Raíces reales y distintas ($discriminante > 0)';
      _pasoRaices = r'm_1 = ' + m1.toStringAsFixed(2) + r', \quad m_2 = ' + m2.toStringAsFixed(2);
      _solucionGeneral = r'y_c(x) = C_1 e^{' + m1.toStringAsFixed(2) + r'x} + C_2 e^{' + m2.toStringAsFixed(2) + r'x}';

      if (_isPVI) {
        // Sistema 2x2: C1 + C2 = y0  =>  m1*C1 + m2*C2 = yp0
        C1 = (yp0 - m2 * y0) / (m1 - m2);
        C2 = y0 - C1;
        _solucionParticular = r'y(x) = (' + C1.toStringAsFixed(2) + r') e^{' + m1.toStringAsFixed(2) + r'x} + (' + C2.toStringAsFixed(2) + r') e^{' + m2.toStringAsFixed(2) + r'x}';
      }

    } else if (discriminante == 0) {
      // CASO 2: Reales y repetidas
      double m = -b / (2 * a);
      _tipoRaices = 'Raíces reales y repetidas ($discriminante = 0)';
      _pasoRaices = r'm_1 = m_2 = ' + m.toStringAsFixed(2);
      _solucionGeneral = r'y_c(x) = C_1 e^{' + m.toStringAsFixed(2) + r'x} + C_2 x e^{' + m.toStringAsFixed(2) + r'x}';

      if (_isPVI) {
        // Sistema: C1 = y0  =>  m*C1 + C2 = yp0
        C1 = y0;
        C2 = yp0 - (m * C1);
        _solucionParticular = r'y(x) = (' + C1.toStringAsFixed(2) + r') e^{' + m.toStringAsFixed(2) + r'x} + (' + C2.toStringAsFixed(2) + r') x e^{' + m.toStringAsFixed(2) + r'x}';
      }

    } else {
      // CASO 3: Complejas conjugadas
      double alpha = -b / (2 * a);
      double beta = sqrt(-discriminante) / (2 * a);
      _tipoRaices = 'Raíces complejas conjugadas ($discriminante < 0)';
      _pasoRaices = r'm = ' + alpha.toStringAsFixed(2) + r' \pm ' + beta.toStringAsFixed(2) + r'i';
      
      String strAlpha = alpha == 0 ? '' : alpha.toStringAsFixed(2);
      String expPart = alpha == 0 ? '' : r'e^{' + strAlpha + r'x} ';
      _solucionGeneral = r'y_c(x) = ' + expPart + r'(C_1 \cos(' + beta.toStringAsFixed(2) + r'x) + C_2 \sin(' + beta.toStringAsFixed(2) + r'x))';

      if (_isPVI) {
        // Sistema: C1 = y0  =>  alpha*C1 + beta*C2 = yp0
        C1 = y0;
        C2 = (yp0 - (alpha * C1)) / beta;
        _solucionParticular = r'y(x) = ' + expPart + r'((' + C1.toStringAsFixed(2) + r') \cos(' + beta.toStringAsFixed(2) + r'x) + (' + C2.toStringAsFixed(2) + r') \sin(' + beta.toStringAsFixed(2) + r'x))';
      }
    }

    setState(() => _mostrarResultado = true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Math.tex(
              r'a y^{\prime\prime} + b y^{\prime} + c y = 0',
              textStyle: TextStyle(fontSize: 22, color: widget.isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 30),

          // Coeficientes a, b, c
          Row(
            children: [
              _buildInput('a', _aController),
              const SizedBox(width: 10),
              _buildInput('b', _bController),
              const SizedBox(width: 10),
              _buildInput('c', _cController),
            ],
          ),
          const SizedBox(height: 20),

          // Switch para PVI
          SwitchListTile(
            title: Text('Añadir Problema de Valor Inicial (PVI)', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            subtitle: Text('Calcular C1 y C2', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54)),
            activeColor: widget.primaryColor,
            value: _isPVI,
            onChanged: (val) => setState(() => _isPVI = val),
          ),

          // Campos para PVI si está activo
          if (_isPVI) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInput('y(0) =', _y0Controller),
                const SizedBox(width: 15),
                _buildInput("y'(0) =", _yPrime0Controller),
              ],
            ),
          ],
          const SizedBox(height: 30),

          // Botón Calcular
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text('Resolver Homogénea', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Resultados
          if (_mostrarResultado) ...[
            const Divider(),
            const SizedBox(height: 10),
            Text('Procedimiento Analítico:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : widget.primaryColor)),
            const SizedBox(height: 15),
            _buildResultBox('Ecuación Característica', r'am^2 + bm + c = 0'),
            _buildResultBox('Tipo de Raíces', _tipoRaices, isText: true),
            _buildResultBox('Raíces (m)', _pasoRaices),
            _buildResultBox('Solución General y_c(x)', _solucionGeneral),
            
            if (_isPVI && _solucionParticular.isNotEmpty)
              _buildResultBox('Solución Particular y(x)', _solucionParticular, isHighlight: true),
          ]
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildResultBox(String title, String content, {bool isText = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlight ? widget.primaryColor.withOpacity(0.1) : (widget.isDark ? const Color(0xFF1C3350) : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isHighlight ? widget.primaryColor : Colors.blue.withOpacity(0.3), width: isHighlight ? 2 : 1),
            ),
            child: isText 
              ? Text(content, style: TextStyle(fontSize: 15, color: widget.isDark ? Colors.amber : widget.primaryColor, fontWeight: FontWeight.bold))
              : Math.tex(content, textStyle: TextStyle(fontSize: 17, color: widget.isDark ? Colors.amber : widget.primaryColor)),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PESTAÑA 2: NO HOMOGÉNEA (INTEGRACIÓN IA)
// =====================================================================
class _NoHomogeneaTab extends StatefulWidget {
  final Color primaryColor;
  final bool isDark;

  const _NoHomogeneaTab({required this.primaryColor, required this.isDark});

  @override
  State<_NoHomogeneaTab> createState() => _NoHomogeneaTabState();
}

class _NoHomogeneaTabState extends State<_NoHomogeneaTab> {
  final TextEditingController _aController = TextEditingController(text: '1');
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  final TextEditingController _fController = TextEditingController();

  void _resolverConIA() {
    if (_fController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa la función f(x)')));
      return;
    }
    
    String eq = "${_aController.text}y'' ";
    if (_bController.text.isNotEmpty && _bController.text != '0') eq += "+ ${_bController.text}y' ";
    if (_cController.text.isNotEmpty && _cController.text != '0') eq += "+ ${_cController.text}y ";
    eq += "= ${_fController.text}";

    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'Solucionador IA',
        contextoDatos: "El usuario necesita resolver la EDO No Homogénea: $eq usando Coeficientes Indeterminados o Variación de Parámetros.",
        colorTema: widget.primaryColor,
        initialMessage: "Por favor, resuelve paso a paso esta ecuación no homogénea: $eq",
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Center(
            child: Math.tex(
              r'a y^{\prime\prime} + b y^{\prime} + c y = f(x)',
              textStyle: TextStyle(fontSize: 22, color: widget.isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 30),

          // Coeficientes a, b, c
          Row(
            children: [
              _buildInput('a', _aController),
              const SizedBox(width: 10),
              _buildInput('b', _bController),
              const SizedBox(width: 10),
              _buildInput('c', _cController),
            ],
          ),
          const SizedBox(height: 20),

          Text('Función No Homogénea f(x):', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: _fController,
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Ej. sin(x) + e^(2x)',
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.functions, color: widget.primaryColor),
            ),
          ),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.primaryColor.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: widget.primaryColor, size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Debido a la complejidad de integración para y_p, el Asistente IA estructurará el método de Variación de Parámetros paso a paso.',
                    style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white70 : Colors.black87),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _resolverConIA,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text('Generar Solución con IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: widget.isDark ? const Color(0xFF234060) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}