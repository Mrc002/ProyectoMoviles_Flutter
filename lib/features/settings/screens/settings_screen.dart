import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';
import '../logic/language_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/logic/auth_provider.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Obtenemos al usuario actual
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    // 2. Verificamos si es invitado (nulo o anónimo)
    final isGuest = user == null || user.isAnonymous;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECCIÓN DE CUENTA DINÁMICA ---
          Padding( 
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), 
            child: Text(
              l10n.cuenta, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: isGuest ? Colors.grey : const Color(0xFF1E88E5), 
                child: Icon(isGuest ? Icons.person_outline : Icons.person, color: Colors.white, size: 28),
              ),
              title: Text(
                // CORRECCIÓN 1: Usamos user!.email porque Dart ya sabe que no es nulo aquí
                isGuest ? l10n.iniciaSesion : (user.email ?? 'Usuario de Math AI'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isGuest ? l10n.iniciaSesionSub : 'Cerrar sesión'),
              trailing: Icon(isGuest ? Icons.arrow_forward_ios : Icons.logout, size: 16, color: isGuest ? Colors.grey : Colors.red),
              onTap: () async {
                await authProvider.signOut();
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN DE PREFERENCIAS ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.preferencias,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Card(
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: Text(l10n.temaOscuro),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        // CORRECCIÓN 2: Se usa activeThumbColor en lugar de activeColor
                        activeThumbColor: const Color(0xFF1E88E5),
                        onChanged: (bool value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56), 
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.idiomaApp), 
                      subtitle: Text(languageProvider.languageName), 
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Select / Selecciona'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Español'),
                                    onTap: () {
                                      languageProvider.changeLanguage('es'); 
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text('English'),
                                    onTap: () {
                                      languageProvider.changeLanguage('en'); 
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN ACERCA DE ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.acercaDe,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.acercaDeSub),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}