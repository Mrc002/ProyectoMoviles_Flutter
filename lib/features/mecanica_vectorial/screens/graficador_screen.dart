import 'package:flutter/material.dart';
import '../../../app.dart';

class GraficadorScreen extends StatefulWidget {
  const GraficadorScreen({super.key});

  @override
  State<GraficadorScreen> createState() => _GraficadorScreenState();
}

class _GraficadorScreenState extends State<GraficadorScreen> {
  // Aquí después conectaremos tu MecanicaProvider para manejar el estado de los vectores

  @override
  Widget build(BuildContext context) {
    // Scaffold sin AppBar porque la barra de navegación ya está en mecanica_main_screen
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Respeta el modo oscuro/claro
      body: Stack(
        children: [
          // 1. ZONA INTERACTIVA: El lienzo (Canvas)
          GestureDetector(
            onPanStart: (details) {
              // TODO: Lógica al empezar a arrastrar (detectar si tocó un nodo/vector)
            },
            onPanUpdate: (details) {
              // TODO: Lógica para actualizar las coordenadas en tiempo real (drag & drop)
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: _DCLPainter(
                gridColor: AppColors.skyBlue.withOpacity(0.1), 
                nodeColor: AppColors.accent, // Naranja para el nodo central
              ),
            ),
          ),

          // 2. INTERFAZ: Menú Flotante Lateral
          Align(
            alignment: Alignment.centerLeft,
            child: _buildFloatingMenu(context),
          ),
          
          // 3. Marca de agua central temporal
          Center(
            child: IgnorePointer( // Para que no interfiera con los toques del canvas
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.architecture, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'Diagrama de Cuerpo Libre',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textSecondary.withOpacity(0.4)
                    ),
                  ),
                  Text(
                    'Selecciona una herramienta del menú flotante\ny toca en el canvas para posicionarla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constructor del menú flotante
  Widget _buildFloatingMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.skyBlueLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón rojo solo para cerrar/borrar
            _ToolButton(
              icon: Icons.close, 
              color: Theme.of(context).colorScheme.error, 
              isOutlined: true, 
              onTap: (){}
            ),
            const SizedBox(height: 8),
            // Resto de herramientas con la paleta de la app
            _ToolButton(icon: Icons.arrow_forward, color: AppColors.skyBlue, onTap: (){}),
            _ToolButton(icon: Icons.refresh, color: AppColors.skyBlueDark, onTap: (){}),
            _ToolButton(icon: Icons.crop_square, color: AppColors.textSecondary, onTap: (){}),
            _ToolButton(icon: Icons.circle_outlined, color: AppColors.textSecondary, onTap: (){}),
            _ToolButton(icon: Icons.change_history, color: AppColors.textSecondary, onTap: (){}),
            _ToolButton(icon: Icons.anchor, color: AppColors.accent, onTap: (){}), // Acento naranja
            _ToolButton(icon: Icons.swap_vert, color: AppColors.textSecondary, onTap: (){}),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET AUXILIAR: Botones del menú flotante
// -----------------------------------------------------------------------------
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ToolButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: isOutlined 
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(icon: Icon(icon, color: color), onPressed: onTap),
          )
        : IconButton(icon: Icon(icon, color: color), onPressed: onTap),
    );
  }
}

// -----------------------------------------------------------------------------
// EL PINCEL NATIVO (CustomPainter)
// -----------------------------------------------------------------------------
class _DCLPainter extends CustomPainter {
  final Color gridColor;
  final Color nodeColor;

  _DCLPainter({required this.gridColor, required this.nodeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dibujar la cuadrícula (Grid) de fondo
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const double gridSize = 40.0;
    
    // Líneas verticales
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Líneas horizontales
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Dibujar el Nodo Origen Base (Centro de la pantalla)
    // En la Fase 1, todos los vectores nacen de aquí
    final Paint nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;
    
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 6.0, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Cambiar a 'true' cuando inyectemos el estado matemático/geométrico (Provider)
    return false; 
  }
}