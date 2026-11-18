import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';   
import 'screens/login_screen.dart';

Future<void> main() async {
  // Enciende el puente nativo antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Conecta la app con tu proyecto de Firebase
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),  
    
    );
  }
}