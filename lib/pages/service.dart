import 'package:emergency/pages/login.dart';
import 'package:emergency/pages/user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Service extends StatelessWidget {
  final String serviceName;
  const Service({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(serviceName),
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
                        content: Text("Unable To logout $e"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Ok"),
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
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection(serviceName).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Emergency will be shown here if available"),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Emergency will be shown here if available"),
              );
            }

            final documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final data = documents[index].data() as Map<String, dynamic>;
                final firstName = data['firstName'] ?? 'Unknown';
                final lastName = data['lastName'] ?? 'Unknown';
                final fullName = firstName + ' ' + lastName;
                final docID = documents[index].id;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersInfo(
                          docid: docID,
                          collectionName: serviceName,
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text(
                              "Are you sure you want to delete this request?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmDelete == true) {
                      FirebaseFirestore.instance
                          .collection(serviceName)
                          .doc(docID)
                          .delete()
                          .catchError((error) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Failed"),
                              content: const Text("Failed to delete request"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok"),
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  },
                  child: ListTile(
                    title: Text(fullName),
                    subtitle: Text(data['phone'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
