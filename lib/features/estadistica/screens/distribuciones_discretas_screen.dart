import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/app_imports.dart';

class DistribucionesDiscretasScreen extends StatefulWidget {
  const DistribucionesDiscretasScreen({super.key});

  @override
  State<DistribucionesDiscretasScreen> createState() => _DistribucionesDiscretasScreenState();
}

class _DistribucionesDiscretasScreenState extends State<DistribucionesDiscretasScreen> {
  String _selectedDist = 'Binomial';
  
  // Controladores de texto
  final _xController = TextEditingController(); 
  final _nController = TextEditingController(); 
  final _pController = TextEditingController(); 
  final _lambdaController = TextEditingController(); 
  final _popNController = TextEditingController(); 
  final _popKController = TextEditingController(); 

  // Variables de estado para los resultados
  double? _probExacta;
  double? _probAcumuladaMenor;
  double? _probAcumuladaMayor; 
  List<double> _distribucionCompleta = []; 
  int _xActual = 0;

  @override
  void dispose() {
    _xController.dispose(); 
    _nController.dispose(); 
    _pController.dispose();
    _lambdaController.dispose(); 
    _popNController.dispose(); 
    _popKController.dispose();
    super.dispose();
  }

  // --- LÓGICA MATEMÁTICA ---
  double _combinatoria(int n, int k) {
    if (k < 0 || k > n) return 0.0;
    if (k == 0 || k == n) return 1.0;
    if (k > n / 2) k = n - k;
    double res = 1.0;
    for (int i = 1; i <= k; i++) {
      res = res * (n - i + 1) / i;
    }
    return res;
  }

  double _poissonProb(double lambda, int x) {
    if (x < 0) return 0.0;
    double res = exp(-lambda);
    for (int i = 1; i <= x; i++) {
      res = res * lambda / i;
    }
    return res;
  }

  void _calcular() {
    setState(() { 
      _probExacta = null; 
      _probAcumuladaMenor = null;
      _probAcumuladaMayor = null;
      _distribucionCompleta = []; 
    });

    if (_selectedDist == 'Binomial') {
      _calcularBinomial();
    } else if (_selectedDist == 'Poisson') {
      _calcularPoisson();
    } else if (_selectedDist == 'Hipergeométrica') {
      _calcularHipergeometrica();
    } else if (_selectedDist == 'Geométrica') {
      _calcularGeometrica();
    }
    
    // Calcular probabilidades acumuladas
    if (_distribucionCompleta.isNotEmpty && _xActual >= 0 && _xActual < _distribucionCompleta.length) {
      double acumulada = 0.0;
      for (int i = 0; i <= _xActual; i++) {
        acumulada += _distribucionCompleta[i];
      }
      
      setState(() {
        _probAcumuladaMenor = acumulada;
        _probAcumuladaMayor = 1.0 - acumulada;
      });
    }
  }

  void _calcularBinomial() {
    int n = int.tryParse(_nController.text) ?? 0;
    double p = double.tryParse(_pController.text) ?? 0.0;
    int x = int.tryParse(_xController.text) ?? 0;

    if (n > 0 && p >= 0 && p <= 1 && x >= 0 && x <= n) {
      List<double> dist = [];
      for (int i = 0; i <= n; i++) {
        dist.add(_combinatoria(n, i) * pow(p, i) * pow(1 - p, n - i));
      }
      setState(() { 
        _probExacta = dist[x]; 
        _distribucionCompleta = dist; 
        _xActual = x; 
      });
    }
  }

  void _calcularPoisson() {
    double lambda = double.tryParse(_lambdaController.text) ?? 0.0;
    int x = int.tryParse(_xController.text) ?? 0;

    if (lambda > 0 && x >= 0) {
      int maxX = max(15, x + 10); 
      List<double> dist = [];
      for (int i = 0; i <= maxX; i++) {
        dist.add(_poissonProb(lambda, i));
      }
      setState(() { 
        _probExacta = dist[x]; 
        _distribucionCompleta = dist; 
        _xActual = x; 
      });
    }
  }

  void _calcularHipergeometrica() {
    int popN = int.tryParse(_popNController.text) ?? 0;
    int popK = int.tryParse(_popKController.text) ?? 0;
    int n = int.tryParse(_nController.text) ?? 0;
    int x = int.tryParse(_xController.text) ?? 0;

    if (popN > 0 && popK >= 0 && popK <= popN && n > 0 && n <= popN && x >= 0 && x <= n && x <= popK) {
      double den = _combinatoria(popN, n);
      int minX = max(0, n - (popN - popK));
      int maxX = min(n, popK);
      
      List<double> dist = List.filled(maxX + 1, 0.0);
      for (int i = minX; i <= maxX; i++) {
        dist[i] = (_combinatoria(popK, i) * _combinatoria(popN - popK, n - i)) / den;
      }
      setState(() { 
        _probExacta = dist[x]; 
        _distribucionCompleta = dist; 
        _xActual = x; 
      });
    }
  }

  void _calcularGeometrica() {
    double p = double.tryParse(_pController.text) ?? 0.0;
    int x = int.tryParse(_xController.text) ?? 0;

    if (p > 0 && p <= 1 && x >= 1) {
      int maxX = max(15, x + 5);
      List<double> dist = List.filled(maxX + 1, 0.0); 
      for (int i = 1; i <= maxX; i++) {
        dist[i] = p * pow(1 - p, i - 1);
      }
      setState(() { 
        _probExacta = dist[x]; 
        _distribucionCompleta = dist; 
        _xActual = x; 
      });
    }
  }

  // --- INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        title: const Text('Distribuciones Discretas', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedDist,
                items: ['Binomial', 'Poisson', 'Hipergeométrica', 'Geométrica']
                    .map((dist) => DropdownMenuItem(value: dist, child: Text(dist)))
                    .toList(),
                onChanged: (val) {
                  setState(() { 
                    _selectedDist = val!; 
                    _probExacta = null; 
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  labelText: 'Familia de Distribución',
                  labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  border: InputBorder.none,
                ),
                dropdownColor: isDark ? const Color(0xFF1C3350) : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            if (_selectedDist == 'Binomial') ...[
              _buildInput(_nController, 'Ensayos totales (n)', isDark),
              _buildInput(_pController, 'Probabilidad de éxito (p)', isDark, isDecimal: true),
              _buildInput(_xController, 'Número de éxitos buscados (x)', isDark),
            ] else if (_selectedDist == 'Poisson') ...[
              _buildInput(_lambdaController, 'Tasa media de ocurrencia (λ)', isDark, isDecimal: true),
              _buildInput(_xController, 'Número de ocurrencias (x)', isDark),
            ] else if (_selectedDist == 'Hipergeométrica') ...[
              _buildInput(_popNController, 'Tamaño de la Población (N)', isDark),
              _buildInput(_popKController, 'Éxitos totales en la población (K)', isDark),
              _buildInput(_nController, 'Tamaño de la muestra (n)', isDark),
              _buildInput(_xController, 'Éxitos buscados (x)', isDark),
            ] else if (_selectedDist == 'Geométrica') ...[
              _buildInput(_pController, 'Probabilidad de éxito (p)', isDark, isDecimal: true),
              _buildInput(_xController, 'Ensayo del 1er éxito (x)', isDark),
            ],
            
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: _calcular,
              icon: const Icon(Icons.analytics_rounded, color: Colors.white),
              label: const Text('Calcular y Graficar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_probExacta != null && _probAcumuladaMenor != null && _probAcumuladaMayor != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _ResultBox('P(X = $_xActual)', _probExacta!, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _ResultBox('P(X ≤ $_xActual)', _probAcumuladaMenor!, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _ResultBox('P(X > $_xActual)', _probAcumuladaMayor!, isDark)),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(
                'Gráfico de Probabilidad (Color Naranja = P(X ≤ $_xActual))',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Container(
                height: 260,
                padding: const EdgeInsets.only(top: 20, right: 16, left: 8, bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _distribucionCompleta.reduce(max) * 1.2, 
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, 
                          getTitlesWidget: (val, _) {
                            int index = val.toInt();
                            if (index >= _distribucionCompleta.length) return const SizedBox();
                            
                            bool showLabel = false;
                            if (_distribucionCompleta.length <= 15) showLabel = true;
                            else if (index % 5 == 0) showLabel = true;
                            else if (index == _xActual) showLabel = true;

                            if (!showLabel) return const SizedBox();

                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                index.toString(), 
                                style: TextStyle(
                                  color: index == _xActual ? Colors.orange : (isDark ? Colors.white54 : Colors.black54), 
                                  fontWeight: index == _xActual ? FontWeight.bold : FontWeight.normal, 
                                  fontSize: 10
                                )
                              ),
                            );
                          }
                        )
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true, 
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.white12 : Colors.black12, 
                        strokeWidth: 1, 
                        dashArray: [5, 5]
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      _distribucionCompleta.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: _distribucionCompleta[index], 
                            color: index <= _xActual ? Colors.orange : const Color(0xFF4CAF50), 
                            width: _distribucionCompleta.length > 20 ? 6 : 14, 
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), 
            ]
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssistant(context),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4,
        child: const Icon(Icons.psychology_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, bool isDark, {bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          filled: true,
          fillColor: isDark ? const Color(0xFF152840) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7)),
          ),
        ),
      ),
    );
  }

  void _showAssistant(BuildContext context) {
    String contexto = "Distribución $_selectedDist. ";
    if (_selectedDist == 'Binomial') {
      contexto += "n=${_nController.text}, p=${_pController.text}, x=${_xController.text}";
    } else if (_selectedDist == 'Poisson') {
      contexto += "λ=${_lambdaController.text}, x=${_xController.text}";
    } else if (_selectedDist == 'Hipergeométrica') {
      contexto += "Población N=${_popNController.text}, Éxitos K=${_popKController.text}, Muestra n=${_nController.text}, x=${_xController.text}";
    } else if (_selectedDist == 'Geométrica') {
      contexto += "p=${_pController.text}, x=${_xController.text}";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MiniChatAssistantStats(contextoDatos: contexto, distribucion: _selectedDist),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String title;
  final double prob;
  final bool isDark;

  const _ResultBox(this.title, this.prob, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5))
      ),
      child: Column(
        children: [
          Text(
            title, 
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54), 
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${(prob * 100).toStringAsFixed(2)}%', 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))
          ),
        ],
      ),
    );
  }
}

class _MiniChatAssistantStats extends StatefulWidget {
  final String contextoDatos;
  final String distribucion;
  const _MiniChatAssistantStats({required this.contextoDatos, required this.distribucion});

  @override
  State<_MiniChatAssistantStats> createState() => _MiniChatAssistantStatsState();
}

class _MiniChatAssistantStatsState extends State<_MiniChatAssistantStats> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  "Tutor IA - ${widget.distribucion}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
                ),
                const Spacer(),
                IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF4CAF50) : (isDark ? const Color(0xFF234060) : const Color(0xFFEBF4FC)),
                      borderRadius: BorderRadius.circular(16).copyWith(bottomRight: msg.isUser ? const Radius.circular(0) : null, bottomLeft: !msg.isUser ? const Radius.circular(0) : null),
                    ),
                    child: Text(msg.text, style: TextStyle(fontSize: 14, color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)))),
                  ),
                );
              },
            ),
          ),
          if (chatProvider.isLoading)
            const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "¿Dudas sobre la ${widget.distribucion}?",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF0F7FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4CAF50),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        chatProvider.sendMessage(
                          _controller.text, 
                          currentEquation: widget.contextoDatos 
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}