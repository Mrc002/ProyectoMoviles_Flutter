import 'package:flutter/material.dart';
import '../../editor/screens/editor_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../editor/logic/editor_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    EditorScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context)!;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isEditor = _selectedIndex == 0;

    return Scaffold(
      appBar: _buildAppBar(context, l10n, isDark, isEditor),
      // AÑADE ESTA LÍNEA PARA EL MENÚ LATERAL:
      drawer: _buildDrawer(context, isDark),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n, isDark),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isEditor,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF5B9BD5),
      elevation: 0,
      titleSpacing: 20,

      // Título con ícono
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.functions, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'Math AI Studio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),

      // Toggle 2D/3D en el AppBar (como en la referencia) — solo visible en Editor
      actions: [
        if (isEditor) _build2D3DToggle(context),
        const SizedBox(width: 12),
      ],

      // Línea decorativa inferior
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  // ── TOGGLE 2D / 3D ──────────────────────────────────────────────────────────
  Widget _build2D3DToggle(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final is3D     = provider.is3DMode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(
            label: '2D',
            isActive: !is3D,
            onTap: () {
              if (is3D) provider.toggleMode();
            },
          ),
          _toggleChip(
            label: '3D',
            isActive: is3D,
            onTap: () {
              if (!is3D) provider.toggleMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF3A7FC1) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAVIGATION ────────────────────────────────────────────────────────
  Widget _buildBottomNav(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _navItem(
                context: context,
                icon: Icons.show_chart_rounded,
                label: l10n.navEstudio,
                index: 0,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.psychology_rounded,
                label: l10n.navAsistente,
                index: 1,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.tune_rounded,
                label: l10n.navAjustes,
                index: 2,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isActive = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Píldora indicadora
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 48 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? const Color(0xFF5B9BD5)
                    : isDark
                        ? Colors.white38
                        : const Color(0xFF6B8CAE),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF5B9BD5)
                      : isDark
                          ? Colors.white38
                          : const Color(0xFF6B8CAE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── MENÚ LATERAL (DRAWER) ───────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF152840) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── HEADER DEL MENÚ ──
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF5B9BD5), 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.functions, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Math AI Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── OPCIONES DEL MENÚ ──
          _buildDrawerItem(
            context: context,
            icon: Icons.calculate_rounded,
            title: 'Álgebra y Funciones',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              // Si ya estás en Álgebra, no haces nada adicional.
            },
          ),
          
          _buildDrawerItem(
            context: context,
            icon: Icons.architecture_rounded,
            title: 'Mecánica Vectorial Estática',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); // Cierra el menú primero
              // TODO: Navegar a la pantalla que creaste de Mecánica Vectorial
              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MecanicaVectorialScreen()),
              );
              */
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.show_chart_rounded, // o Icons.waves
            title: 'Ecuaciones Diferenciales',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              // TODO: Navegar a la pantalla de Ecuaciones Diferenciales
              /*
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EcuacionesDiferencialesScreen()),
              );
              */
            },
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para estilizar cada elemento de la lista del menú
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : const Color(0xFF6B8CAE),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A2D4A),
        ),
      ),
      onTap: onTap,
    );
  }