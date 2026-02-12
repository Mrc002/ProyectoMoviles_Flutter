import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/editor_provider.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que la pantalla se redibuje con los cambios
    final provider = context.watch<EditorProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- BOTÓN TOGGLE 2D / 3D (Solicitado) ---
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(child: _ModeButton(label: "2D", isActive: !provider.is3DMode)),
                Expanded(child: _ModeButton(label: "3D", isActive: provider.is3DMode)),
              ],
            ),
          ),

          // --- LIENZO INFINITO (Estilo Desmos) ---
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    // CORRECCIÓN 1: withValues en lugar de withOpacity
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: provider.is3DMode
                  ? _build3DPlaceholder()
                  : GestureDetector(
                      // Gestos para mover y hacer zoom
                      onScaleStart: (details) => provider.startGesture(details),
                      onScaleUpdate: (details) {
                        final size = context.size ?? Size.zero;
                        provider.updateGesture(details, size);
                      },
                      child: LineChart(
                        LineChartData(
                          minX: provider.minX, maxX: provider.maxX,
                          minY: provider.minY, maxY: provider.maxY,
                          clipData: const FlClipData.all(),
                          gridData: FlGridData(
                            show: true,
                            // Cuadrícula dinámica que se adapta al zoom
                            horizontalInterval: (provider.maxY - provider.minY) / 6,
                            verticalInterval: (provider.maxX - provider.minX) / 6,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? Colors.black : Colors.grey.shade200,
                              strokeWidth: value.abs() < 0.1 ? 2 : 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? Colors.black : Colors.grey.shade200,
                              strokeWidth: value.abs() < 0.1 ? 2 : 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: provider.points,
                              isCurved: true,
                              color: theme.primaryColor,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                        duration: Duration.zero, // Sin animación para respuesta inmediata
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),

          // --- CAMPO DE FÓRMULA ---
          TextField(
            onChanged: (value) => provider.updateEquation(value),
            decoration: InputDecoration(
              labelText: provider.is3DMode ? 'Función f(x, y)' : 'Función f(x)',
              hintText: provider.is3DMode ? 'Ej. x^2 + y^2' : 'Ej. sin(x) * x',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.functions, color: provider.isValid ? theme.primaryColor : Colors.red),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_in_ar, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 10),
          Text("Modo 3D", style: TextStyle(color: Colors.grey[400], fontSize: 20)),
        ],
      ),
    );
  }
}

// Botón personalizado para el toggle superior
class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ModeButton({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) context.read<EditorProvider>().toggleMode();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          // CORRECCIÓN 2: withValues aquí también
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}