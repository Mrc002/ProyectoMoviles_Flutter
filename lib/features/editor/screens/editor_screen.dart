import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/editor_provider.dart';
import '../../../l10n/app_localizations.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; // Detectamos si es modo oscuro
    final l10n = AppLocalizations.of(context)!;

    // Colores dinámicos según el tema
    final containerColor = theme.colorScheme.surface;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final gridLineColor = isDark ? Colors.white10 : Colors.grey.shade200;
    final mainAxisLineColor = isDark ? Colors.white54 : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- BOTÓN TOGGLE 2D / 3D ---
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              // Usamos el color de superficie del tema en lugar de grey[100]
              color: isDark ? Colors.black26 : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(child: _ModeButton(label: "2D", isActive: !provider.is3DMode)),
                Expanded(child: _ModeButton(label: "3D", isActive: provider.is3DMode)),
              ],
            ),
          ),

          // --- LIENZO INFINITO ---
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                // Usamos el color de superficie dinámico en lugar de Colors.white
                color: containerColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: provider.is3DMode
                  ? _build3DPlaceholder(context)
                  : GestureDetector(
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
                            horizontalInterval: (provider.maxY - provider.minY) / 6,
                            verticalInterval: (provider.maxX - provider.minX) / 6,
                            // Líneas de la cuadrícula dinámicas
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? mainAxisLineColor : gridLineColor,
                              strokeWidth: value.abs() < 0.1 ? 2 : 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? mainAxisLineColor : gridLineColor,
                              strokeWidth: value.abs() < 0.1 ? 2 : 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: provider.points,
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                        duration: Duration.zero, 
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),

          // --- CAMPO DE FÓRMULA ---
          // Ya no necesitamos configurar colores aquí porque los definimos en el main.dart
          TextField(
            onChanged: (value) => provider.updateEquation(value),
            decoration: InputDecoration(
              labelText: provider.is3DMode ? l10n.editorFuncion3D : l10n.editorFuncion2D,
              hintText: provider.is3DMode ? l10n.editorHint3D : l10n.editorHint2D,
              prefixIcon: Icon(
                Icons.functions, 
                // El icono también se adapta
                color: provider.isValid ? theme.colorScheme.primary : theme.colorScheme.error
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.view_in_ar, size: 80, color: isDark ? Colors.white24 : Colors.grey[200]),
          const SizedBox(height: 10),
          Text(
            l10n.editorModo3D, 
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[400], fontSize: 20)
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ModeButton({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Color del texto del botón
    final textColor = isActive 
        ? (isDark ? theme.colorScheme.onSurface : Colors.black87)
        : (isDark ? Colors.white54 : Colors.grey[500]);

    // Color del fondo del botón activo
    final activeBackgroundColor = isDark ? theme.colorScheme.surface : Colors.white;

    return GestureDetector(
      onTap: () {
        if (!isActive) context.read<EditorProvider>().toggleMode();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}