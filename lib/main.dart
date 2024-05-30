import 'package:emergency/pages/user.dart';
import 'package:emergency/pages/login.dart';
import 'package:emergency/pages/register.dart';
import 'package:emergency/pages/service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(), // Login screen
        '/register': (context) => const Register(), // Register screen
        '/electric': (context) => const Service(serviceName: "Electric",), // Electric role
        '/pestcontrol': (context) => const Service(serviceName: "Pest Control",), // Pest control role
        '/firefighter': (context) => const Service(serviceName: "Fire Fighter",), // Fire Fighter role
        '/hospital': (context) => const Service(serviceName: "Hospital",), // Hospital role
        '/animalshelter': (context) => const Service(serviceName: "Animal Shelter",), // Animal Shelter role
        '/police': (context) => const Service(serviceName: "Police",), // Police role
        '/user': (context) => const User(), // Default user role
      },
      title: 'Emergency App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
