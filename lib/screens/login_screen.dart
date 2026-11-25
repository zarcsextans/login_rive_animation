import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar timer
//5.1 Importar Firebase Auth y la pantalla de productos
import 'package:firebase_auth/firebase_auth.dart';
import 'products_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
//control para mostrar la contraseña/ocultar la contraseña
   bool _isObsure = true;

//1.1 Crear un controlador de animación Rive
StateMachineController? _controller;
//1.2 SMI: StateMachineInput/ entrada de la máquina de estados
SMIBool? _isChecking;
SMIBool? _isHandsUp;
SMITrigger? _trigSuccess;
SMITrigger? _trigFail;
SMINumber? _numLook;

//3.2 Timer para detener la mirada al dejar de escribir 
Timer? _typingDebounce;

//Crear variables para focusNode
final _emailFocusNode = FocusNode();
final _passwordFocusNode = FocusNode();

//4.1 controllers para panipular el texto excrito por el usuario
final  emailCtrl=TextEditingController();
final passCtrl=TextEditingController();//pregunta de examen: ¿para que sirve el controller? para manipular el texto escrito por el usuario
// se puede usar para obtener el texto escrito por el usuario, para limpiar el campo de texto, para establecer un valor inicial, etc.
//final cvvCtrl=TextEditingController(); 

/*4.2 Errores para mostrar en la UI
String? emailError;
String? passError;
*/

//5.2 Variable para mostrar el CircularProgressIndicator mientras carga
bool _isLoading = false;

 // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  /*bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }*/

  //4.4 Dar acción al botón
  //5.3 Convertir _onLogin en asíncrono (Future<void> ... async)
  Future<void> _onLogin() async {
  final email = emailCtrl.text.trim();
  final pass = passCtrl.text;

  // Cerrar el teclado y bajar las manos del osito
  FocusScope.of(context).unfocus();
  _typingDebounce?.cancel();
  _isHandsUp?.change(false);
  _isChecking?.change(false);
  _numLook?.value = 50.0;

  // Validar únicamente que los campos no estén vacíos
  if (email.isEmpty || pass.isEmpty) {
    _trigFail?.fire();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completa el correo y la contraseña.'),
      ),
    );
    return;
  }

  // Activar el indicador de carga
  setState(() {
    _isLoading = true;
  });

  try {
    // Autenticar en Firebase
    await Future.delayed(const Duration(seconds: 2));

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    // Apagar loading y activar animación de éxito
    setState(() {
      _isLoading = false;
    });

    _trigSuccess?.fire();

    await Future.delayed(const Duration(seconds: 2));

    // Navegar a la pantalla de productos
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductsScreen(),
      ),
    );

  } catch (e) {
    // Credenciales incorrectas: apagar loading y activar fallo
    setState(() {
      _isLoading = false;
    });

    _trigFail?.fire();

    // Mostrar un único mensaje general
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Credenciales inválidas. Verifica tu correo y contraseña.',
        ),
      ),
    );
  }

  }

//2.2 Crear los listenses(Oyentes/Chismosos)
@override
void initState() {
  super.initState();
  _emailFocusNode.addListener((){
    if (_emailFocusNode.hasFocus) {
      // El campo de correo electrónico tiene el foco
      if (_isHandsUp != null) {
        //ojos sin cerrar en email
        _isHandsUp!.change(false);
        _numLook?.value = 50; // Mira neutral
      }
    }
  });
  _passwordFocusNode.addListener((){ 
    //manos arriba en password
    _isHandsUp?.change(_passwordFocusNode.hasFocus);
  });
}
  @override
  Widget build(BuildContext context) {
    // Obtiene el tamaño de la pantalla
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox( //contine la animacion de Rive
                  width: screenSize.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/login-bear-animation.riv',
                    stateMachines: ['Login Machine'],
                    //1.3 Vincular la animación con el controlador de la máquina de estados
                    onInit:(artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard, 
                        'Login Machine',
                      );

                      //1.4 verificar que inicio bien
                     if (_controller == null) return;
                    
                    artboard.addController(_controller!);

                    //vincular las variables 
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                    _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                //para separar el RiveAnimation del resto de los elementos
                SizedBox(height: 10),
                // texfield es para elegir el tipo de teclado
                TextField(
                  //4.8 vincular el controller al campo de texto
                  controller: emailCtrl,
                  //2.3 Asignar el foco al campo de texto
                  focusNode: _emailFocusNode,
                  //1.5 Vincular a campos de texto
                  onChanged: (value) {
                    //1.5 Cambiar el valor de la variable de la máquina de estados
                    if(_isHandsUp != null) {
                      // No tapes los ojos cuando escribas en el correo electrónico
                     // _isHandsUp!.change(false);
                    }

                    if(_isChecking == null) return;
                    _isChecking!.change(true);
                    //3.4 Implementar numLook 
                    // Ajustes del 0 al 100
                    // 80 es medida de calibración. Clam es el rango (abrazadera) esto es de examen
                    final look = (value.length /80.0 *100).clamp(0.0, 100.0);
                    _numLook?.value = look;
                    //3.5 Debounce: si vuelve a teclear, reinicia el cotador 
                    _typingDebounce?.cancel();
                    //crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), (){
                      // Si se cierra la pantalla(!mounted)
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  },
                  //Para mostrar el teclado de correo electrónico
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //contraseña
                TextField(
                  //4.8. vincular el controller al campo de texto
                  controller: passCtrl,
                  //2.3 Asignar el foco al campo de texto
                   focusNode: _passwordFocusNode,
                   onChanged: (value) {
                    //1.5 Cambiar el valor de la variable de la máquina de estados
                    if(_isChecking  != null) {
                      // no tapes los ojos cuando escribas en la contraseña
                     // _isChecking!.change(false);
                    }
                    if(_isHandsUp == null) return;
                    _isHandsUp!.change(true);
                  },
                  obscureText: _isObsure,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObsure ? Icons.visibility : Icons.visibility_off),//icono para mostrar la contraseña
                      onPressed: () {
                        //Para refrescar el icono
                        setState(() {
                          _isObsure = !_isObsure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                SizedBox(
                  width: screenSize.width,
                  child: const Text(
                    "Forgot Password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),
                                //4.13 Botón de login
                MaterialButton(
                  minWidth: screenSize.width,
                  height: 50,
                  color: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _onLogin,
                  //5.9 Mostrar CircularProgressIndicator si está cargando, o el texto Login
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                //¿no tienes cuenta? creala
                const SizedBox(height: 20),
                SizedBox(
                  width: screenSize.width,
                  child: Row(
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                      )
                    ],
                    
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    //4.10 Liberar los controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    //2.4 Liberar los recursos de los focusNode
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.5 Liberar Timer 
    _typingDebounce?.cancel();
    super.dispose();
  }
}