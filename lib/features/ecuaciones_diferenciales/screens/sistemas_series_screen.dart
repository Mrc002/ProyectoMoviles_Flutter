import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';
import 'ed_chat_sheet.dart'; // Importamos el componente centralizado

class SistemasSeriesScreen extends StatefulWidget {
  const SistemasSeriesScreen({Key? key}) : super(key: key);

  @override
  State<SistemasSeriesScreen> createState() => _SistemasSeriesScreenState();
}

class _SistemasSeriesScreenState extends State<SistemasSeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('Sistemas');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Color verde asignado en el GridView
    final primaryColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistemas y Series'),
        backgroundColor: isDark ? const Color(0xFF1C3350) : primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFEBF4FC),
        child: provider.isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.temasCargados.length,
                itemBuilder: (context, index) {
                  final tema = provider.temasCargados[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isDark ? Colors.transparent : primaryColor.withOpacity(0.3), width: 1),
                    ),
                    color: isDark ? const Color(0xFF1C3350) : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.account_tree, color: primaryColor),
                      ),
                      title: Text(
                        tema['titulo'] ?? 'Tema sin título',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue[900]),
                      ),
                      subtitle: Text(
                        'Fuente: ${tema['bibliografia'] ?? 'Edwards & Penney'}',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TemaDetalleScreen(tema: tema),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssistant(context, primaryColor),
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  void _showAssistant(BuildContext context, Color color) {
    String contexto = "El usuario está en el menú de Sistemas de Ecuaciones y Series de Fourier explorando los temas disponibles, basados en Edwards & Penney.";
    context.read<ChatProvider>().setSection('Ecuaciones Diferenciales');

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => EdChatSheet(
        moduleName: 'Sistemas y Series',
        contextoDatos: contexto,
        colorTema: color,
      )
    );
  }
}