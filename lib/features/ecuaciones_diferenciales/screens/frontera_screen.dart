import 'package:flutter/material.dart';

class FronteraScreen extends StatelessWidget {
  const FronteraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valores en la Frontera'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blue[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.border_outer, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 20),
            Text(
              'Módulo de Frontera',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),
            Text(
              'Teoría de Sturm-Liouville y puente hacia las EDPs.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blue[700]),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}