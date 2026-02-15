import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/theme_provider.dart';
import '../logic/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECCIÓN DE CUENTA ---
          Padding( 
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), 
            child: Text(
              AppLocalizations.of(context)!.cuenta, 
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
              title: const Text(
                'Inicia Sesión o Regístrate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Guarda tus gráficos y chats en la nube'),
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
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Preferencias',
              style: TextStyle(
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
                      title: const Text('Tema Oscuro'),
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
                
                // CONSUMER ACTUALIZADO PARA IDIOMA GLOBAL
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    final l10n = AppLocalizations.of(context)!; 

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
              ], // <--- ESTOS CORCHETES Y PARÉNTESIS FALTABAN
            ),
          ),
          const SizedBox(height: 24),

          // --- SECCIÓN ACERCA DE ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Acerca de',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueGrey
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de Math AI Studio'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}