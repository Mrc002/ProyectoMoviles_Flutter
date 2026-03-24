import 'package:flutter/material.dart';
import 'edo_screen.dart';
import 'sistemas_series_screen.dart';
import 'frontera_screen.dart';
import 'edp_screen.dart';
// Nuevas importaciones de los módulos que acabamos de crear
import 'segundo_orden_screen.dart';
import 'laplace_modulo_screen.dart';

class EcuacionesMainScreen extends StatelessWidget {
  const EcuacionesMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detección del tema para mantener la consistencia con Álgebra y Estadística
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC);

    // Definición de los 6 módulos propuestos para el grid, ahora todos conectados
    final modules = [
      {
        'title': 'EDOs de 1er Orden',
        'subtitle': 'Separables, Exactas, Bernoulli',
        'icon': Icons.looks_one_rounded,
        'color': const Color(0xFF5B9BD5),
        'screen': const EdoScreen(),
      },
      {
        'title': '2do Orden Lineal',
        'subtitle': 'Coeficientes Cte, Variación Parámetros',
        'icon': Icons.looks_two_rounded,
        'color': const Color(0xFF7C6BBD),
        'screen': const SegundoOrdenScreen(), // Ya conectado
      },
      {
        'title': 'Laplace',
        'subtitle': 'Transformada, Tabla, Heaviside',
        'icon': Icons.functions_rounded,
        'color': const Color(0xFFE67E3A),
        'screen': const LaplaceModuloScreen(), // Ya conectado
      },
      {
        'title': 'Sistemas de ED',
        'subtitle': 'Valores propios, Plano de fase',
        'icon': Icons.account_tree_rounded,
        'color': const Color(0xFF4CAF50),
        'screen': const SistemasSeriesScreen(),
      },
      {
        'title': 'Series y Frobenius',
        'subtitle': 'Potencias, Bessel, Legendre',
        'icon': Icons.timeline_rounded,
        'color': const Color(0xFFE91E63),
        'screen': const FronteraScreen(),
      },
      {
        'title': 'EDPs',
        'subtitle': 'Onda, Calor, Laplace',
        'icon': Icons.waves_rounded,
        'color': const Color(0xFF00ACC1),
        'screen': const EdpScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ecuaciones Diferenciales'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : const Color(0xFF5B9BD5),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85, // Ajustado para que el texto e íconos respiren
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final mod = modules[index];
          return _buildModuleCard(
            context,
            mod['title'] as String,
            mod['subtitle'] as String,
            mod['icon'] as IconData,
            mod['color'] as Color,
            mod['screen'] as Widget?,
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color color, 
    Widget? screen, 
    bool isDark
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1C3350) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          } else {
            // Mostrar un SnackBar amigable si algún módulo llega a ser null en el futuro
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('El módulo "$title" está en desarrollo.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}