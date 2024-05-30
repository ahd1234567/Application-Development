// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency/widgets/textfield.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  DateTime? _selectedDate;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format the selected date without time
        String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        dobController.text =
            formattedDate; // Set the formatted date to the controller
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
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
                    "Signing up...",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      );
      try {
        // Create a new user with email and password
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Get the newly created user's UID
        String uid = userCredential.user!.uid;

        // Create a new document for this user in Firestore
        DocumentReference userDoc =
            FirebaseFirestore.instance.collection("users").doc(uid);

        await userDoc.set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'dob': dobController.text, // Date of birth
          'gender': _selectedGender,
          'role': 'user', // Default role (or based on a dropdown or user input)
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Sign in Successful'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // After successful registration, navigate back to the login screen
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle errors (e.g., email already in use, weak password, etc.)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failed'),
              content: const Text('User already exists'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    dobController.addListener(() {
      // Parse the text to DateTime when it changes
      if (dobController.text.isNotEmpty) {
        _selectedDate = DateTime.parse(dobController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              const Center(
                child: Text(
                  "Create an account",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                preicon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "First Name",
                controller: firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Last Name",
                controller: lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.email,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Email",
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.lock,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Password",
                obscureText: true,
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.phone,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Phone Number",
                keyboard: TextInputType.number,
                controller: phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              CustomTextField(
                preicon: const Icon(
                  Icons.event,
                  color: Color.fromARGB(255, 255, 94, 1),
                ),
                hint: "Date of Birth (yyyy-mm-dd)",
                controller: dobController,
                ontap: () => selectDate(context),
                readonly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Select Gender',
                    prefixIcon: Icon(
                      _selectedGender == 'Male'
                          ? Icons.male
                          : _selectedGender == 'Female'
                              ? Icons.female
                              : FontAwesomeIcons.venusMars,
                      color: const Color.fromARGB(255, 255, 94, 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 106, 166),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 106, 166),
                      ),
                    ),
                  ),
                  value: _selectedGender,
                  hint: const Text('Select Gender'),
                  items: <String>['Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register, // Call the registration function
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(100, 10),
                  backgroundColor: const Color.fromARGB(255, 255, 94, 1),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Signup"),
              ),
              const SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already a member?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/");
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 94, 1),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
