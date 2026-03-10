import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../logic/mecanica_provider.dart';
import '../../chat/screens/chat_screen.dart';

class IaTutorScreen extends StatelessWidget {
  const IaTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Usamos Column para que el Chat pueda expandirse dinámicamente
      body: Column(
        children: [
          // ── 1. ENCABEZADO ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppColors.skyBlue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Math IA Tutor',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tu asistente inteligente para resolver problemas.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. ESTADO DEL DIAGRAMA ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildInfoCard(
              context: context,
              icon: Icons.architecture_rounded,
              title: 'Estado del Diagrama',
              value: provider.isCanvasEmpty 
                  ? 'Canvas vacío. Dibuja para comenzar.' 
                  : 'Diagrama activo con ${provider.vectores.length} vectores.',
              isDark: isDark,
              isHighlight: true, // Lo resaltamos un poco
            ),
          ),
          const SizedBox(height: 12),

          // ── 3. COMENZAR TUTORÍA (CHAT GLOBAL) ──
          // Usamos Expanded para que el chat tome el espacio del medio y el teclado funcione bien
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.skyBlueLight, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera de la tarjeta del chat
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: const Text(
                      'Comenzar Tutoría',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.skyBlueDark),
                    ),
                  ),
                  const Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                      child: ChatScreen(), 
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 4. GUÍA PASO A PASO (DATOS DETERMINISTAS DEL MOTOR) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUÍA PASO A PASO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 12, 
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Estos datos provienen 100% del código en Dart, NO de la IA
                _buildInfoCard(
                  context: context,
                  icon: Icons.search_rounded,
                  title: '1. Identificar incógnitas',
                  value: provider.incognitasIdentificadas,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context: context,
                  icon: Icons.functions_rounded,
                  title: '2. Ecuaciones de equilibrio',
                  value: provider.ecuacionesEquilibrio,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context: context,
                  icon: Icons.check_circle_outline_rounded,
                  title: '3. Resultado final',
                  value: provider.resultadoFinal,
                  isDark: isDark,
                ),
                const SizedBox(height: 16), // Espacio para el BottomNavBar
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para las tarjetas de información (Estado y Matemáticas)
  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon, 
    required String title, 
    required String value,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? AppColors.skyBlue : (isDark ? AppColors.darkBorder : AppColors.divider),
          width: isHighlight ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlight ? AppColors.skyBlue : AppColors.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 12, 
                    color: isHighlight ? (isDark ? Colors.white : Colors.black87) : AppColors.textSecondary
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