import 'dart:io';
import 'dart:convert'; // <--- NUEVO: Para decodificar la imagen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/logic/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Función para decidir cómo dibujar la imagen
  ImageProvider? _getImageProvider(String photoData) {
    if (photoData.isEmpty) return null;
    if (photoData.startsWith('http')) {
      return NetworkImage(photoData); // Es un robot de DiceBear
    } else {
      return MemoryImage(base64Decode(photoData)); // Es tu foto en Base64
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            GestureDetector(
              onTap: () => authProvider.isLoading 
                  ? null 
                  : _showAvatarPicker(context, authProvider, isDark),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: authProvider.isPremium ? const Color(0xFFFFD700) : const Color(0xFF5B9BD5),
                      // USAMOS NUESTRA NUEVA FUNCIÓN AQUÍ
                      image: authProvider.photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: _getImageProvider(authProvider.photoUrl)!,
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (authProvider.isPremium ? Colors.amber : const Color(0xFF5B9BD5)).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: authProvider.photoUrl.isEmpty
                        ? Icon(
                            authProvider.isPremium ? Icons.workspace_premium : Icons.person,
                            color: Colors.white,
                            size: 50,
                          )
                        : null,
                  ),
                  
                  if (authProvider.isLoading)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BD5),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC), width: 3),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    )
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                        Text('Estado de la Cuenta', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
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
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); 
                await authProvider.signOut(); 
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AuthProvider authProvider, bool isDark) {
    final List<String> appAvatars = [
      'https://api.dicebear.com/9.x/bottts/png?seed=Math1',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math2',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math3',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math4',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math5',
      'https://api.dicebear.com/9.x/bottts/png?seed=Math6',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF152840) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecciona un Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))),
              const SizedBox(height: 20),
              
              SizedBox(
                height: 150,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: appAvatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        authProvider.updateProfilePicture(appAvatars[index]);
                        Navigator.pop(context); 
                      },
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFEBF4FC),
                        backgroundImage: NetworkImage(appAvatars[index]),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF5B9BD5).withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Color(0xFF5B9BD5)),
                ),
                title: Text('Subir desde la galería', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context); 
                  
                  final ImagePicker picker = ImagePicker();
                  // IMPORTANTE: Comprimimos la imagen al 15% de su calidad original 
                  // para que quepa como texto en Firestore
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 15, // <--- COMPRESIÓN AGREGADA
                  );
                  
                  if (image != null) {
                    await authProvider.uploadProfileImage(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}