import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final String label;
  final String value;
  const CustomTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

