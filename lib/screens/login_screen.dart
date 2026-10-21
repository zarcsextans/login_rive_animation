import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 Importar el timer
 
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

//2.1 Crear variables para focusNode
final _emailFocusNode = FocusNode();
final _passwordFocusNode = FocusNode();

//2.2 Crear los listeners (Oyentes/Chismosos)
@override
void initState() {
  super.initState();
  _emailFocusNode.addListener(() {
    if (_emailFocusNode.hasFocus) {
      //Verificar que no sea nulo
      if(_isHandsUp != null) {
        //Ojos sin cerrar en email
        _isHandsUp?.change(false);
        _numLook?.value = 50; //3.3 Mirada neutral
      }
    }
  });
  _passwordFocusNode.addListener((){
    //Manos arriba en passwordd
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
                //Email
                TextField(
                  //2.3 Asignar foco al campo de texto
                  focusNode: _emailFocusNode,
                  //1.5 Vincular a campos de texto
                  onChanged: (value) {
                    if(_isHandsUp != null) {
                      //No tapes los ojos
                      _isHandsUp!.change(false);
                    }
                    //Si isCheking es null
                    if(_isChecking == null) return;
                    //Activar el modo chismoso
                    _isChecking!.change(true);
                    //3.4 Implementar numLook
                    //Ajustes del 0 al 100
                    //80 es medida de calibración. Clamp es el rango (abrazadera)
                    final look = (value.length / 50.0 *100).clamp(0.0, 100.0);
                    _numLook?.value = look;
                  
                    //3.5 Debounce: Si vuelve a teclear, reinicia el contador
                    _typingDebounce
                        ?.cancel(); //Cancelamos cualquier timer existente
                    //Crear nuevo Timer
                    _typingDebounce = Timer(const Duration(seconds: 3),(){
                      //Si se cierra la pantalla (!mounted)
                      if(!mounted) return;
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
                  //2.3 Asignar foco al campo de texto
                  focusNode: _passwordFocusNode,
                  //1.5 Vincular a campos de texto
                   onChanged: (value) {
                    if(_isChecking  != null) {
                      //No tapes los ojos
                      _isChecking!.change(false);
                    }
                    //Si isCheking es null
                    if(_isHandsUp == null) return;
                    //Activar el modo chismoso
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    //2.4 Liberar recursos de los focusNode
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.5 Liberar Timer
    _typingDebounce?.cancel();
    super.dispose();
  }
}
 