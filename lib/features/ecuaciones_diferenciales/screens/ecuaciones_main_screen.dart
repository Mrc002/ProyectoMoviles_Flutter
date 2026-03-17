import 'package:flutter/material.dart';
import 'edo_screen.dart';
import 'sistemas_series_screen.dart';
import 'frontera_screen.dart';
import 'edp_screen.dart';

class EcuacionesMainScreen extends StatelessWidget {
  const EcuacionesMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecuaciones Diferenciales'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.blue[50],
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 10),
            _buildTopicCard(
              context,
              'Ecuaciones Diferenciales Ordinarias',
              'Conceptos, EDOs de 1er y orden superior, Laplace.',
              Icons.functions,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdoScreen())),
            ),
            _buildTopicCard(
              context,
              'Sistemas de Ecuaciones y Series',
              'Valores propios, matrices fundamentales y series de Fourier.',
              Icons.account_tree,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SistemasSeriesScreen())),
            ),
            _buildTopicCard(
              context,
              'Problemas con Valores en la Frontera',
              'Teoría de Sturm-Liouville y aplicaciones.',
              Icons.border_outer,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FronteraScreen())),
            ),
            _buildTopicCard(
              context,
              'Ecuaciones en Derivadas Parciales',
              'Ecuación de onda, calor, Laplace y separación de variables.',
              Icons.waves,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdpScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                child: Icon(icon, color: Colors.blue[800], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.blue[800], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}