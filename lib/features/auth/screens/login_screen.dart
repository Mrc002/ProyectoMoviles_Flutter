import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController     = TextEditingController();

  bool _isLoginMode    = true;
  bool _obscurePass    = true;
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth     = Provider.of<AuthProvider>(context, listen: false);
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name     = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    String? error;
    if (_isLoginMode) {
      error = await auth.signInWithEmailAndPassword(email, password);
    } else {
      if (name.isEmpty) return;
      error = await auth.createUserWithEmailAndPassword(email, password, name);
    }

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLoginMode = !_isLoginMode);
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      // Fondo con gradiente azul suave como la referencia
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F1E2E), const Color(0xFF1C3350)]
                : [const Color(0xFFD6E8F7), const Color(0xFFEBF4FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── LOGO / HEADER ────────────────────────────────────
                      _buildHeader(isDark, l10n),
                      const SizedBox(height: 36),

                      // ── CARD FORMULARIO ──────────────────────────────────
                      _buildFormCard(auth, isDark, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Ícono con fondo azul como en la referencia
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9BD5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B9BD5).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.functions, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Math AI Studio',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.graficaAnaliza,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── CARD FORMULARIO ─────────────────────────────────────────────────────────
  Widget _buildFormCard(AuthProvider auth, bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF234060)
              : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del modo
          Text(
            _isLoginMode ? l10n.iniciarSesionBtn : l10n.crearCuentaBtn,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2D4A),
            ),
          ),
          const SizedBox(height: 24),

          // Campo nombre (solo en registro)
          if (!_isLoginMode) ...[
            _buildField(
              controller: _nameController,
              label: l10n.nombreCompleto,
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          // Email
          _buildField(
            controller: _emailController,
            label: l10n.correoElectronico,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Contraseña
          _buildField(
            controller: _passwordController,
            label: l10n.contrasena,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePass,
            isDark: isDark,
            suffix: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF6B8CAE),
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          const SizedBox(height: 24),

          // Botón principal
          auth.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF5B9BD5),
                    ),
                  ),
                )
              : _buildPrimaryButton(
                  label: _isLoginMode ? l10n.iniciarSesionBtn : l10n.registrarseBtn,
                  onTap: _submit,
                ),

          const SizedBox(height: 12),

          // Continuar como invitado (solo en login)
          if (_isLoginMode && !auth.isLoading)
            _buildSecondaryButton(
              label: l10n.continuarInvitado,
              onTap: () async {
                final error = await auth.signInAsGuest();
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: const Color(0xFFE53935),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              isDark: isDark,
            ),

          // Divider decorativo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark
                        ? const Color(0xFF234060)
                        : const Color(0xFFD6E8F7),
                  ),
                ),
              ],
            ),
          ),

          // Toggle login / registro
          Center(
            child: GestureDetector(
              onTap: _toggleMode,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
                  ),
                  children: [
                    TextSpan(
                      text: _isLoginMode
                          ? l10n.noTienesCuenta
                          : l10n.yaTienesCuenta,
                    ),
                    TextSpan(
                      text: _isLoginMode ? l10n.registrateAccion : l10n.iniciaSesionAccion,
                      style: const TextStyle(
                        color: Color(0xFF5B9BD5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CAMPO DE TEXTO ──────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A2D4A),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF5B9BD5)),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? const Color(0xFF152840)
            : const Color(0xFFF0F7FF),
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
        labelStyle: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── BOTÓN PRINCIPAL ─────────────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9BD5).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTÓN SECUNDARIO ────────────────────────────────────────────────────────
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF152840)
              : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}