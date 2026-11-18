import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  // Mostrar u ocultar contraseñas
  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;

  // Indicador de carga
  bool _isLoading = false;

  // Validar correo institucional
  bool isValidEmail(String email) {
    final re = RegExp(
      r'^[a-zA-Z0-9._%+-]+@tecdesoftware\.edu\.mx$',
    );
    return re.hasMatch(email);
  }

  // Validar contraseña
  bool isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // Registrar usuario en Firebase
  Future<void> _onRegister() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      // Cerrar la sesión creada automáticamente por Firebase
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Avisar que el registro fue exitoso
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Registro exitoso'),
            content: const Text(
              'Tu cuenta se creó correctamente. Ya puedes iniciar sesión.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Regresar al Login
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String message = 'No se pudo completar el registro.';

      if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña no cumple los requisitos.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es válido.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al registrar la cuenta.'),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                'Registro de usuario',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Correo institucional
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo institucional',
                  hintText: 'usuario@tecdesoftware.edu.mx',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo institucional';
                  }

                  if (!isValidEmail(value.trim())) {
                    return 'Utiliza un correo @tecdesoftware.edu.mx';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Contraseña
              TextFormField(
                controller: passCtrl,
                obscureText: _isPasswordObscure,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscure = !_isPasswordObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una contraseña';
                  }

                  if (!isValidPassword(value)) {
                    return 'La contraseña no cumple los requisitos';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              // Requisitos de contraseña
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'La contraseña debe contener:\n'
                  '• Mínimo 8 caracteres\n'
                  '• Una letra mayúscula\n'
                  '• Una letra minúscula\n'
                  '• Un número\n'
                  '• Un símbolo especial',
                  style: TextStyle(fontSize: 13),
                ),
              ),

              const SizedBox(height: 20),

              // Confirmar contraseña
              TextFormField(
                controller: confirmPassCtrl,
                obscureText: _isConfirmObscure,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmObscure = !_isConfirmObscure;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }

                  if (value != passCtrl.text) {
                    return 'Las contraseñas no coinciden';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              // Botón de registro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Registrarme'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }
}