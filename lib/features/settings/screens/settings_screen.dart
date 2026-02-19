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
    final l10n         = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user         = authProvider.user;
    final isGuest      = user == null || user.isAnonymous;
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [

          // ── CARD DE CUENTA ──────────────────────────────────────────────
          _SectionLabel(label: l10n.cuenta, isDark: isDark),
          const SizedBox(height: 10),
          _AccountCard(
            isGuest: isGuest,
            user: user,
            isDark: isDark,
            l10n: l10n,
            onTap: () async => await authProvider.signOut(),
          ),

          const SizedBox(height: 24),

          // ── PREFERENCIAS ────────────────────────────────────────────────
          _SectionLabel(label: l10n.preferencias, isDark: isDark),
          const SizedBox(height: 10),
          _PreferencesCard(isDark: isDark, l10n: l10n),

          const SizedBox(height: 24),

          // ── ACERCA DE ───────────────────────────────────────────────────
          _SectionLabel(label: l10n.acercaDe, isDark: isDark),
          const SizedBox(height: 10),
          _AboutCard(isDark: isDark, l10n: l10n),

          const SizedBox(height: 32),

          // ── VERSIÓN ─────────────────────────────────────────────────────
          Center(
            child: Text(
              'Math AI Studio v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white24 : const Color(0xFFB0CDE8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── LABEL DE SECCIÓN ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : const Color(0xFF6B8CAE),
        ),
      ),
    );
  }
}

// ── CARD BASE ─────────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ── CARD DE CUENTA ────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final bool isGuest;
  final dynamic user;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _AccountCard({
    required this.isGuest,
    required this.user,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isGuest
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF5B9BD5), Color(0xFF3A7FC1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isGuest ? Colors.grey : const Color(0xFF5B9BD5))
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest
                          ? l10n.iniciaSesion
                          : (user?.email ?? 'Usuario'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A2D4A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isGuest ? l10n.iniciaSesionSub : 'Cuenta registrada',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFF6B8CAE),
                      ),
                    ),
                  ],
                ),
              ),

              // Acción
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isGuest
                        ? const Color(0xFF5B9BD5)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isGuest ? 'Entrar' : 'Salir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isGuest
                          ? Colors.white
                          : const Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── CARD DE PREFERENCIAS ──────────────────────────────────────────────────────
class _PreferencesCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _PreferencesCard({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        // Tema oscuro
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return _SettingsTile(
              isDark: isDark,
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF5B9BD5),
              title: l10n.temaOscuro,
              trailing: _StyledSwitch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),
              showDivider: true,
            );
          },
        ),

        // Idioma
        Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return _SettingsTile(
              isDark: isDark,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFFF5A623),
              title: l10n.idiomaApp,
              subtitle: languageProvider.languageName,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
              ),
              showDivider: false,
              onTap: () => _showLanguageDialog(context, languageProvider),
            );
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider languageProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1C3350) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        title: Text(
          'Seleccionar idioma',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A2D4A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              flag: '🇲🇽',
              label: 'Español',
              isSelected: languageProvider.languageName == 'Español',
              isDark: isDark,
              onTap: () {
                languageProvider.changeLanguage('es');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              flag: '🇺🇸',
              label: 'English',
              isSelected: languageProvider.languageName == 'English',
              isDark: isDark,
              onTap: () {
                languageProvider.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── CARD ACERCA DE ────────────────────────────────────────────────────────────
class _AboutCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _AboutCard({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          isDark: isDark,
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF5B9BD5),
          title: l10n.acercaDeSub,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
          ),
          showDivider: true,
          onTap: () {},
        ),
        _SettingsTile(
          isDark: isDark,
          icon: Icons.star_outline_rounded,
          iconColor: const Color(0xFFF5A623),
          title: 'Valorar la app',
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white38 : const Color(0xFFB0CDE8),
          ),
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }
}

// ── TILE GENÉRICO ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Ícono con fondo de color
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),

                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A2D4A),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF6B8CAE),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFEBF4FC),
          ),
      ],
    );
  }
}

// Switch con estilo custom
class _StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StyledSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF5B9BD5),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFD6E8F7),
    );
  }
}

// Opción de idioma en el dialog
class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5B9BD5).withValues(alpha: 0.12)
              : (isDark ? const Color(0xFF152840) : const Color(0xFFF0F7FF)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B9BD5)
                : (isDark
                    ? const Color(0xFF234060)
                    : const Color(0xFFD6E8F7)),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF5B9BD5)
                    : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF5B9BD5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}