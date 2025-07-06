// lib/views/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signIn(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${e.toString}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: ${e.toString}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<ChallengeController>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error con Google: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a Retos Diarios')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Inicia Sesión o Regístrate', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email no válido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                   validator: (value) => (value == null || value.length < 6) ? 'La contraseña debe tener al menos 6 caracteres' : null,
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _signUp,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Registrarse'),
                      ),
                       
                       // --- INICIO DEL CÓDIGO DEL BOTÓN DE GOOGLE ---
                       const SizedBox(height: 20),
                       const Row(
                         children: [
                           Expanded(child: Divider()),
                           Padding(
                             padding: EdgeInsets.symmetric(horizontal: 8.0),
                             child: Text('O'),
                           ),
                           Expanded(child: Divider()),
                         ],
                       ),
                       const SizedBox(height: 20),
                       ElevatedButton.icon(
                         onPressed: _signInWithGoogle,
                         icon: Image.asset('assets/google_logo.png', height: 24.0),
                         label: const Text('Iniciar Sesión con Google'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.black,
                           padding: const EdgeInsets.symmetric(vertical: 12),
                         ),
                       ),
                       // --- FIN DEL CÓDIGO DEL BOTÓN DE GOOGLE ---
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}