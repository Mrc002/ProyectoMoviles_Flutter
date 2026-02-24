import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/logic/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Si por alguna razón un invitado llega aquí, le mostramos un aviso
    if (user == null || user.isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Inicia sesión para ver tu perfil.')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- AVATAR GIGANTE ---
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: authProvider.isPremium ? const Color(0xFFFFD700) : const Color(0xFF5B9BD5),
                boxShadow: [
                  BoxShadow(
                    color: (authProvider.isPremium ? Colors.amber : const Color(0xFF5B9BD5)).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(
                authProvider.isPremium ? Icons.workspace_premium : Icons.person,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),

            // --- NOMBRE Y CORREO ---
            Text(
              authProvider.userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
            ),
            const SizedBox(height: 5),
            Text(
              user.email ?? '',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : const Color(0xFF6B8CAE)),
            ),
            const SizedBox(height: 30),

            // --- TARJETA DE ESTADO PREMIUM ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C3350) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: authProvider.isPremium ? Colors.amber : (isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7))),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(
                    authProvider.isPremium ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: authProvider.isPremium ? Colors.amber : Colors.grey,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de la Cuenta',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey),
                        ),
                        Text(
                          authProvider.isPremium ? 'Usuario PREMIUM' : 'Usuario Básico (Gratis)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: authProvider.isPremium ? Colors.amber : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- BOTÓN DE MEJORAR (Solo si es gratis) ---
            if (!authProvider.isPremium)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Aquí pondremos la pantalla de pago después
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: Mejorar a Premium')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9BD5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Mejorar a Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            
            const Spacer(),

            // --- BOTÓN DE CERRAR SESIÓN ---
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerramos la pantalla de perfil
                await authProvider.signOut(); // Cerramos sesión
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}