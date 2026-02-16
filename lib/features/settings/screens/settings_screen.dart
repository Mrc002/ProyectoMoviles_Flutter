import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';
import '../logic/language_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Declaramos l10n aquí arriba para usarlo en toda la pantalla
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECCIÓN DE CUENTA ---
          Padding( 
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), 
            child: Text(
              l10n.cuenta, 
              style: const TextStyle( 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueGrey
              ),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF1E88E5), 
                child: Icon(Icons.person_outline, color: Colors.white, size: 28),
              ),
              title: Text(
                l10n.iniciaSesion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.iniciaSesionSub),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Integración de cuentas'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN DE PREFERENCIAS ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              l10n.preferencias,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueGrey
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                // CONSUMER DEL TEMA OSCURO
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: Text(l10n.temaOscuro),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        activeColor: const Color(0xFF1E88E5),
                        onChanged: (bool value) {
                          themeProvider.toggleTheme(value);
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56), 
                
                // CONSUMER DE IDIOMA
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
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueGrey
              ),
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