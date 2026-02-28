import 'package:flutter/material.dart';
import '../../editor/screens/editor_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../editor/logic/editor_provider.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../chat/logic/chat_provider.dart'; 

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

      actions: [
        if (isEditor) _build2D3DToggle(context),
        const SizedBox(width: 12),
      ],

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

  // ── MENÚ LATERAL (DRAWER) ───────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    final isGuest = authProvider.user == null || authProvider.user!.isAnonymous;
    final userName = isGuest ? 'Invitado' : authProvider.userName;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF152840) : Colors.white,
      child: Column(
        children: [
          // ── HEADER DEL MENÚ ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF5B9BD5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hola, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── OPCIONES FIJAS (Tus herramientas) ──
          _buildDrawerItem(
            context: context,
            icon: Icons.calculate_rounded,
            title: 'Álgebra y Funciones',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); 
            },
          ),
          
          // ¡AQUÍ ESTÁN DE VUELTA TUS DOS APARTADOS!
          _buildDrawerItem(
            context: context,
            icon: Icons.architecture_rounded,
            title: 'Mecánica Vectorial Estática',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context); // Cierra el menú primero
              // TODO: Navegar a la pantalla que creaste de Mecánica Vectorial
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
            },
          ),
          
          const Divider(),

          // ── SECCIÓN DE HISTORIAL DE IA ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de IA',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isGuest)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: isDark ? Colors.white70 : const Color(0xFF5B9BD5)),
                    tooltip: 'Nuevo Chat',
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<ChatProvider>().clearChat();
                      setState(() => _selectedIndex = 1);
                    },
                  )
              ],
            ),
          ),

          // ── LÓGICA DE INVITADO VS REGISTRADO ──
          if (isGuest)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: isDark ? Colors.white30 : Colors.black26),
                      const SizedBox(height: 16),
                      Text(
                        'Inicia sesión o regístrate para guardar tu historial de conversaciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  
                  if (chatProvider.chatSessions.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay chats recientes',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      )
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: chatProvider.chatSessions.length,
                    itemBuilder: (context, index) {
                      final session = chatProvider.chatSessions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline, 
                          color: isDark ? Colors.white70 : const Color(0xFF6B8CAE)
                        ),
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Cierra el menú
                          chatProvider.loadChatSession(session.id); // Carga la conversación
                          
                          // Cambia a la pestaña del chat si no estás en ella
                          setState(() => _selectedIndex = 1);
                        },
                      );
                    },
                  );
                },
              ),
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
}