import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Control {
  Future<void> sendData(String collectionName, LatLng position) async {
    try {
      // Retrieve data from users collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      // Check if user data exists
      if (userSnapshot.exists) {
        // Retrieve user data
        Map<String, dynamic> userData =
            userSnapshot.data()! as Map<String, dynamic>;

        userData['latitude'] = position.latitude;

        userData['longitude'] = position.longitude;

        // Send the retrieved data as a new document to the Police collection
        await FirebaseFirestore.instance
            .collection(collectionName)
            .add(userData);

        // Data sent successfully
        debugPrint('Data sent to Police collection successfully.');
      } else {
        // User data not found
        debugPrint('User data not found.');
      }
    } catch (e) {
      // Error occurred
      debugPrint('Error sending data to Police collection: $e');
    }
  }
}
