import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency/control.dart';
import 'package:emergency/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async'; // Import for StreamSubscription

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final locationController = Location();
  LatLng? currentPosition;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await fetchLocationUpdates());
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void onTap(String station, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text('Are you sure you want to request $name to your location?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (currentPosition != null) {
                  Control().sendData(station, currentPosition!);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content: Text('$name will be sent to your location ASAP'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('We could not locate your location. Please try again!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...'); 
              }
      
              var firstName = snapshot.data?['firstName'];
      
              return Text(firstName ?? 'No Name');
            },
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                try {
                  FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Failed"),
                        content: Text("Unable to logout: $e"),
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
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      onTap("Police", "Police");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/police1.jpg",
                          height: 100,
                          width: 150,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                            child: Text(
                              "Police",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 65,
                  ),
                  InkWell(
                    onTap: () {
                      onTap("Hospital", "Ambulance");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/ambulance.jpg",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Ambulance",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      onTap("Fire Fighter", "Fire Fighter");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/firefighter.jpg",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Fire Fighter",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  InkWell(
                    onTap: () {
                      onTap("Electric", "Electrician");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/electric.jpg",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 11,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                            child: Text(
                              "Electric",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      onTap("Animal Shelter", "Animal Shelter");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/animal.jpg",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Text(
                              "Animal Shelter",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 65,
                  ),
                  InkWell(
                    onTap: () {
                      onTap("Pest Control", "Pest Control");
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/pest.jpg",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // Add border color
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                            child: Text(
                              "Pest Control",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
