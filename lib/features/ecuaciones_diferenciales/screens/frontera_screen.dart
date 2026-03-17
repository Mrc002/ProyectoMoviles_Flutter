import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/ecuaciones_provider.dart';
import 'tema_detalle_screen.dart';
import '../../chat/logic/chat_provider.dart';
import '../../chat/screens/chat_screen.dart';

class FronteraScreen extends StatefulWidget {
  const FronteraScreen({Key? key}) : super(key: key);

  @override
  State<FronteraScreen> createState() => _FronteraScreenState();
}

class _FronteraScreenState extends State<FronteraScreen> {
  @override
  void initState() {
    super.initState();
    // Le pedimos al provider que traiga los temas de 'Frontera'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcuacionesProvider>().fetchTemasPorCategoria('Frontera');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EcuacionesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valores en la Frontera'),
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
                        child: Icon(Icons.border_outer, color: Colors.blue[800]),
                      ),
                      title: Text(
                        tema['titulo'] ?? 'Tema sin título',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                      ),
                      subtitle: Text('Fuente: ${tema['bibliografia'] ?? 'Edwards & Penney'}'),
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
          context.read<ChatProvider>().setSection('Ecuaciones Diferenciales (Frontera)');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}