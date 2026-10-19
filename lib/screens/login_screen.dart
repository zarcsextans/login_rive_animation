import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
 
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
                  onChanged: (value) {
                    //1.5 Cambiar el valor de la variable de la máquina de estados
                    if(_isHandsUp != null) {
                      _isHandsUp!.change(false);
                    }
 
                    if(_isChecking == null) return;
                    _isChecking!.change(true);
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
                   onChanged: (value) {
                    //1.5 Cambiar el valor de la variable de la máquina de estados
                    if(_isChecking  != null) {
                      _isChecking!.change(false);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 