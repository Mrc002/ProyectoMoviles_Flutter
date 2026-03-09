import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ScanProblemScreen extends StatefulWidget {
  final String tema; // <-- Agregamos esta variable

  // Modificamos el constructor para pedir el tema obligatoriamente
  const ScanProblemScreen({super.key, required this.tema}); 

  @override
  State<ScanProblemScreen> createState() => _ScanProblemScreenState();
}

class _ScanProblemScreenState extends State<ScanProblemScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Función para abrir la cámara/galería y luego RECORTAR
  Future<void> _pickImage(ImageSource source) async {
    try {
      // 1. Tomar la foto
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // Calidad máxima para el OCR
      );

      if (pickedFile != null) {
        // 2. Abrir la pantalla para recortar la imagen
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 800,       
          maxHeight: 800,      
          compressQuality: 85, 
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Enfocar Fórmula',
              toolbarColor: const Color(0xFF5B9BD5), 
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Enfocar Fórmula',
              doneButtonTitle: 'Aceptar',
              cancelButtonTitle: 'Cancelar',
            ),
          ],
        );

        // 3. Si el usuario recortó la imagen y le dio aceptar
        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      debugPrint("Error al seleccionar o recortar imagen: $e");
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
                label: 'Resolver Problema',
                color: Colors.green.shade600,
                isLarge: true,
                onTap: () async {
                  if (_selectedImage == null) return;

                  // 1. Mostrar un indicador de carga en pantalla
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // 2. Preparar la imagen para enviarla a tu servidor Python
                    // IMPORTANTE: Cambia esta URL por la que te dé Render cuando subas tu Python
                    var uri = Uri.parse('https://juancarlos2431-api-matematicas.hf.space/escanear/${widget.tema}'); 
                    var request = http.MultipartRequest('POST', uri);
                    
                    request.files.add(
                      await http.MultipartFile.fromPath('file', _selectedImage!.path)
                    );

                    // 3. Enviar y esperar la respuesta de Python
                    var response = await request.send();
                    var responseData = await response.stream.bytesToString();
                    var jsonResponse = json.decode(responseData);

                    // Quitar el círculo de carga
                    Navigator.pop(context);

                    if (jsonResponse['success'] == true) {
                      String formulaDetectada = jsonResponse['formula_detectada'];
                      String resultadoFinal = jsonResponse['resultado'];

                      // 4. Mostrar el resultado en el recuadro que creamos
                      _mostrarResultadoDialog(context, formulaDetectada, resultadoFinal);
                      
                    } else {
                      // Ahora atrapamos el error real y lo mostramos en pantalla
                      String errorReal = jsonResponse['error'] ?? 'Error desconocido';
                      String formulaLeida = jsonResponse['formula_detectada'] ?? '';
                      
                      // Mostramos un cuadro de alerta con el detalle exacto
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ops! Algo falló'),
                          content: Text('La IA leyó esto: $formulaLeida\n\nPero el motor matemático dijo: $errorReal'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            )
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // Quitar carga en caso de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error de conexión con el servidor: $e')),
                    );
                  }
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

void _mostrarResultadoDialog(BuildContext context, String formula, String resultado) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Separar las soluciones por \quad para mostrarlas individualmente
  List<String> soluciones = resultado
      .split(r', \quad ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Para que no se corte si hay muchas soluciones
    backgroundColor: isDark ? const Color(0xFF1C3350) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              'Solución Encontrada ✓',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A2D4A),
              ),
            ),
            const SizedBox(height: 24),

            // Fórmula detectada
            const Text('Problema detectado:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Math.tex(
                  formula,
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resultados — uno por uno
            const Text('Resultado:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),

            // Si hay varias soluciones las mostramos en tarjetas separadas
            ...soluciones.map((sol) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF5B9BD5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Math.tex(
                  sol,
                  textStyle: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B9BD5),
                  ),
                ),
              ),
            )),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    },
  );
}