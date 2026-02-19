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
    final theme    = Theme.of(context);
    final isDark   = theme.brightness == Brightness.dark;
    final l10n     = AppLocalizations.of(context)!;

    return Container(
      color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LIENZO DE GRÁFICA ─────────────────────────────────────────
            Expanded(
              child: _GraphCard(provider: provider, isDark: isDark, l10n: l10n),
            ),

            const SizedBox(height: 16),

            // ── PANEL INFERIOR: Fórmula + Info ───────────────────────────
            _BottomPanel(provider: provider, isDark: isDark, l10n: l10n),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── CARD DE LA GRÁFICA ────────────────────────────────────────────────────────
class _GraphCard extends StatelessWidget {
  final EditorProvider provider;
  final bool isDark;
  final AppLocalizations l10n;

  const _GraphCard({
    required this.provider,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFD6E8F7);
    final axisColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF5B9BD5).withValues(alpha: 0.6);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234060)
              : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: provider.is3DMode
          ? _build3DPlaceholder(context)
          : Stack(
              children: [
                // Gráfica
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: provider.startGesture,
                    onScaleUpdate: (details) {
                      final size = context.size ?? Size.zero;
                      provider.updateGesture(details, size);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          minX: provider.minX,
                          maxX: provider.maxX,
                          minY: provider.minY,
                          maxY: provider.maxY,
                          clipData: const FlClipData.all(),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval:
                                (provider.maxY - provider.minY) / 8,
                            verticalInterval:
                                (provider.maxX - provider.minX) / 8,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? axisColor : gridColor,
                              strokeWidth: value.abs() < 0.1 ? 1.5 : 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: value.abs() < 0.1 ? axisColor : gridColor,
                              strokeWidth: value.abs() < 0.1 ? 1.5 : 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: provider.points,
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF5B9BD5),
                                  const Color(0xFF3A7FC1),
                                ],
                              ),
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF5B9BD5).withValues(alpha: 0.15),
                                    const Color(0xFF5B9BD5).withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                  ),
                ),

                // Badge con el modo actual
                Positioned(
                  top: 12,
                  left: 12,
                  child: _GraphBadge(isDark: isDark),
                ),

                // Hint de zoom
                if (provider.points.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 56,
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFD6E8F7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresa una función para graficar',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFB0CDE8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _build3DPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF234060)
                  : const Color(0xFFEBF4FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.view_in_ar_rounded,
              size: 40,
              color: isDark
                  ? Colors.white24
                  : const Color(0xFFB0CDE8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.editorModo3D,
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Próximamente',
            style: TextStyle(
              color: isDark ? Colors.white24 : const Color(0xFFD6E8F7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Badge "2D" o "3D" encima de la gráfica
class _GraphBadge extends StatelessWidget {
  final bool isDark;
  const _GraphBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5B9BD5).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF5B9BD5).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        provider.is3DMode ? '3D' : '2D',
        style: const TextStyle(
          color: Color(0xFF5B9BD5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── PANEL INFERIOR ────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final EditorProvider provider;
  final bool isDark;
  final AppLocalizations l10n;

  const _BottomPanel({
    required this.provider,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = provider.isValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234060)
              : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Etiqueta
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                size: 16,
                color: isValid
                    ? const Color(0xFF5B9BD5)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 6),
              Text(
                provider.is3DMode
                    ? l10n.editorFuncion3D
                    : l10n.editorFuncion2D,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white54
                      : const Color(0xFF6B8CAE),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // Indicador válido/inválido
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isValid
                      ? const Color(0xFF5B9BD5).withValues(alpha: 0.1)
                      : const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isValid ? 'Válida ✓' : 'Inválida',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isValid
                        ? const Color(0xFF5B9BD5)
                        : const Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Campo de texto
          TextField(
            onChanged: provider.updateEquation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: provider.is3DMode
                  ? l10n.editorHint3D
                  : l10n.editorHint2D,
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : const Color(0xFFB0CDE8),
                fontFamily: 'monospace',
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF152840)
                  : const Color(0xFFF0F7FF),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF5B9BD5),
                  width: 2,
                ),
              ),
              suffixIcon: provider.equation.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: const Color(0xFF6B8CAE),
                      onPressed: () => provider.updateEquation(''),
                    )
                  : null,
            ),
          ),

          // Info rápida del rango
          if (isValid) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _RangeChip(
                  label: 'X',
                  range:
                      '${provider.minX.toStringAsFixed(1)} → ${provider.maxX.toStringAsFixed(1)}',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _RangeChip(
                  label: 'Y',
                  range:
                      '${provider.minY.toStringAsFixed(1)} → ${provider.maxY.toStringAsFixed(1)}',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Chip de rango X / Y
class _RangeChip extends StatelessWidget {
  final String label;
  final String range;
  final bool isDark;

  const _RangeChip({
    required this.label,
    required this.range,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF152840)
            : const Color(0xFFEBF4FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234060)
              : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B9BD5),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}