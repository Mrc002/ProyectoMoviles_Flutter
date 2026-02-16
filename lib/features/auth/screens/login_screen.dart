import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Nuevo para registro
  
  bool _isLoginMode = true; // Alternar entre Login y Registro

  void _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    String? error;

    if (_isLoginMode) {
      error = await authProvider.signInWithEmailAndPassword(email, password);
    } else {
      if (name.isEmpty) return; // Validación extra para registro
      error = await authProvider.createUserWithEmailAndPassword(email, password, name);
    }

    // Si hubo error, mostrar una alerta
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
    // Si fue exitoso, el AuthWrapper de app.dart detectará el cambio y nos mandará al HomeScreen automáticamente.
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.psychology, size: 80, color: theme.primaryColor),
              const SizedBox(height: 20),
              Text(
                'Math AI Studio',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
              const SizedBox(height: 40),

              if (!_isLoginMode) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isLoginMode ? 'INICIAR SESIÓN' : 'REGISTRARSE'),
                    ),
              
              if (_isLoginMode && !authProvider.isLoading)
                TextButton(
                  onPressed: () async {
                    final error = await authProvider.signInAsGuest();
                    if (error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Continuar como Invitado', style: TextStyle(color: Colors.grey)),
                ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(_isLoginMode ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}