import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';
import '../../mecanica_vectorial/screens/ia_tutor_screen.dart';

class EdpScreen extends StatefulWidget {
  const EdpScreen({Key? key}) : super(key: key);

  @override
  State<EdpScreen> createState() => _EdpScreenState();
}

class _EdpScreenState extends State<EdpScreen> {
  @override
  void initState() {
    super.initState();
    // Le pedimos al provider que traiga los temas de 'EDPs'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('EDPs');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Derivadas Parciales'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.blue[50],
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
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
                      side: BorderSide(color: Colors.blue.shade100, width: 1),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.waves, color: Colors.blue[800]),
                      ),
                      title: Text(
                        tema['titulo'] ?? 'Tema sin título',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                      ),
                      subtitle: Text('Fuente: ${tema['bibliografia'] ?? 'Hans F. Weinberger'}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                      onTap: () {
                        // Navegación al detalle del tema
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
      
      // Botón flotante conectado a la IA con su contexto específico
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ChatProvider>().setSection('Ecuaciones Diferenciales (EDPs)');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IaTutorScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}