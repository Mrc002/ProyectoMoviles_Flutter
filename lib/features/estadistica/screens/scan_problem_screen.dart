import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanProblemScreen extends StatefulWidget {
  const ScanProblemScreen({super.key});

  @override
  State<ScanProblemScreen> createState() => _ScanProblemScreenState();
}

class _ScanProblemScreenState extends State<ScanProblemScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Función para abrir la cámara o la galería
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Calidad alta para que la IA pueda leer bien las fórmulas
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  // Función para borrar la foto actual y tomar otra
  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1A2D4A)),
        title: Text(
          'Escanear Problema',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2D4A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ÁREA DE LA IMAGEN ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C3350) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF234060) : const Color(0xFFD6E8F7),
                    width: 2,
                  ),
                ),
                child: _selectedImage == null
                    ? _buildPlaceholder(isDark)
                    : _buildImagePreview(),
              ),
            ),
            
            const SizedBox(height: 24),

            // --- BOTONES INFERIORES ---
            if (_selectedImage == null) ...[
              // Si NO hay foto, mostramos los botones para tomarla
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Cámara',
                      color: const Color(0xFF5B9BD5),
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      color: const Color(0xFF6B8CAE),
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Si YA HAY foto, mostramos el botón gigante de Resolver
              _buildActionButton(
                icon: Icons.auto_awesome,
                label: 'Resolver con IA',
                color: Colors.green.shade600,
                isLarge: true,
                onTap: () {
                  // TODO: Aquí conectaremos el Provider de Gemini
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Analizando con IA...')),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.refresh, color: Colors.redAccent),
                label: const Text('Tomar otra foto', style: TextStyle(color: Colors.redAccent)),
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE DISEÑO ---
  
  Widget _buildPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner_rounded, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Toma una foto de tu problema\nde probabilidad o estadística',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white54 : const Color(0xFF6B8CAE),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        _selectedImage!,
        fit: BoxFit.contain, // Muestra la imagen completa sin recortarla
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isLarge ? 60 : 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: isLarge ? 28 : 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}