// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    color: Color.fromARGB(255, 255, 94, 1)),
                SizedBox(height: 16),
                Text(
                  "Logging in...",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid);

      DocumentSnapshot userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        String userRole = userSnapshot["role"];

        if (userRole == "Electric") {
          Navigator.pushReplacementNamed(context, '/electric');
        } else if (userRole == "Pest Control") {
          Navigator.pushReplacementNamed(context, '/pestcontrol');
        } else if (userRole == "Fire Fighter") {
          Navigator.pushReplacementNamed(context, '/firefighter');
        } else if (userRole == "Hospital") {
          Navigator.pushReplacementNamed(context, '/hospital');
        } else if (userRole == "Animal Shelter") {
          Navigator.pushReplacementNamed(context, '/animalshelter');
        } else if (userRole == "Police") {
          Navigator.pushReplacementNamed(context, '/police');
        } else {
          Navigator.pushReplacementNamed(context, '/user');
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Failed"),
              content: const Text("User data not found"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Failed"),
            content: const Text("Invalid email or password"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                "assets/alarm.jpg",
                height: 200,
              ),
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                preicon: const Icon(
                  Icons.email,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Email",
                controller: emailController,
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Password",
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login, 
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(100, 10),
                  backgroundColor: const Color.fromARGB(255, 255, 94, 1),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Login"),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text("Not a member?"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/register");
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 5),
                  backgroundColor: const Color.fromARGB(255, 255, 94, 1),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Create an Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
