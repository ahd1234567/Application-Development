import 'package:emergency/pages/map.dart';
import 'package:emergency/widgets/tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersInfo extends StatelessWidget {
  final String collectionName;
  final String docid;

  const UsersInfo(
      {super.key, required this.docid, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .doc(docid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTile(
                        label: "First Name", value: userData['firstName']),
                    CustomTile(label: "Last Name", value: userData['lastName']),
                    CustomTile(label: "Phone", value: userData['phone']),
                    CustomTile(label: "Gender", value: userData['gender']),
                    CustomTile(label: "Date of Birth", value: userData['dob']),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GMap(
                              userLat: userData['latitude'],
                              userLong: userData["longitude"],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(350, 10),
                        backgroundColor: const Color.fromARGB(255, 255, 94, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Get Location"),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
