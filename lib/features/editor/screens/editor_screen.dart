import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/editor_provider.dart';
import '../widgets/graph_3d_view.dart';
import '../../../l10n/app_localizations.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final l10n     = AppLocalizations.of(context)!;

    return Container(
      color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _GraphCard(provider: provider, isDark: isDark, l10n: l10n),
            ),
            const SizedBox(height: 16),
            _BottomPanel(provider: provider, isDark: isDark, l10n: l10n),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── CARD DE LA GRÁFICA ───────────────────────────────────────────────────────
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
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
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
          ? Graph3DView(isDark: isDark, l10n: l10n)
          : Stack(
              children: [
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
                            horizontalInterval: (provider.maxY - provider.minY) / 8,
                            verticalInterval: (provider.maxX - provider.minX) / 8,
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
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

                // Badge "2D"
                Positioned(
                  top: 12,
                  left: 12,
                  child: _GraphBadge(isDark: isDark),
                ),

                // Estado vacío
                if (provider.points.isEmpty)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 56,
                          color: isDark ? Colors.white12 : const Color(0xFFD6E8F7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.ingresaFuncion,
                          style: TextStyle(
                            color: isDark ? Colors.white24 : const Color(0xFFB0CDE8),
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
}

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
        border: Border.all(color: const Color(0xFF5B9BD5).withValues(alpha: 0.3)),
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

// ── PANEL INFERIOR ───────────────────────────────────────────────────────────
class _BottomPanel extends StatefulWidget {
  final EditorProvider provider;
  final bool isDark;
  final AppLocalizations l10n;

  const _BottomPanel({
    required this.provider,
    required this.isDark,
    required this.l10n,
  });

  @override
  State<_BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<_BottomPanel> {
  // ⚠️ CLAVE: el controller se maneja aquí, no se recrea en cada build
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.provider.is3DMode
          ? widget.provider.equation3D
          : widget.provider.equation,
    );
  }

  @override
  void didUpdateWidget(covariant _BottomPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el modo (2D↔3D), actualizar el texto del campo
    if (oldWidget.provider.is3DMode != widget.provider.is3DMode) {
      final newText = widget.provider.is3DMode
          ? widget.provider.equation3D
          : widget.provider.equation;
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = widget.provider.isValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
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
          // Etiqueta + indicador válido/inválido
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                size: 16,
                color: isValid ? const Color(0xFF5B9BD5) : const Color(0xFFE53935),
              ),
              const SizedBox(width: 6),
              Text(
                widget.provider.is3DMode
                    ? widget.l10n.editorFuncion3D
                    : widget.l10n.editorFuncion2D,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isValid
                      ? const Color(0xFF5B9BD5).withValues(alpha: 0.1)
                      : const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isValid ? widget.l10n.funcionValida : widget.l10n.funcionInvalida,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isValid ? const Color(0xFF5B9BD5) : const Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Campo de texto — usa el controller del State, no se recrea
          TextField(
            controller: _textController,
            onChanged: widget.provider.updateEquation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.isDark ? Colors.white : const Color(0xFF1A2D4A),
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: widget.provider.is3DMode
                  ? 'Ej: sin(x)*cos(y), x^2-y^2'
                  : widget.l10n.editorHint2D,
              hintStyle: TextStyle(
                color: widget.isDark ? Colors.white24 : const Color(0xFFB0CDE8),
                fontFamily: 'monospace',
              ),
              filled: true,
              fillColor: widget.isDark
                  ? const Color(0xFF152840)
                  : const Color(0xFFF0F7FF),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? const Color(0xFF234060)
                      : const Color(0xFFD6E8F7),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF5B9BD5), width: 2),
              ),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: const Color(0xFF6B8CAE),
                      onPressed: () {
                        _textController.clear();
                        widget.provider.updateEquation('');
                      },
                    )
                  : null,
            ),
          ),

          // Chips de sugerencia para 3D
          if (widget.provider.is3DMode) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: EditorProvider.example3DFunctions
                    .map((fn) => _FunctionChip(
                          fn: fn,
                          isDark: widget.isDark,
                          onTap: () {
                            _textController.value = TextEditingValue(
                              text: fn,
                              selection: TextSelection.collapsed(offset: fn.length),
                            );
                            widget.provider.updateEquation(fn);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],

          // Rango X/Y en modo 2D
          if (isValid && !widget.provider.is3DMode) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _RangeChip(
                  label: 'X',
                  range:
                      '${widget.provider.minX.toStringAsFixed(1)} → ${widget.provider.maxX.toStringAsFixed(1)}',
                  isDark: widget.isDark,
                ),
                const SizedBox(width: 8),
                _RangeChip(
                  label: 'Y',
                  range:
                      '${widget.provider.minY.toStringAsFixed(1)} → ${widget.provider.maxY.toStringAsFixed(1)}',
                  isDark: widget.isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FunctionChip extends StatelessWidget {
  final String fn;
  final bool isDark;
  final VoidCallback onTap;

  const _FunctionChip({required this.fn, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF152840) : const Color(0xFFEBF4FC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
          ),
        ),
        child: Text(
          fn,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: isDark ? const Color(0xFF5B9BD5) : const Color(0xFF3A7FC1),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final String range;
  final bool isDark;

  const _RangeChip({required this.label, required this.range, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : const Color(0xFFEBF4FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5B9BD5))),
          Text(range,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}