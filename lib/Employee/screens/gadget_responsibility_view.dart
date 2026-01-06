import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';

class GadgetResponsibilityView extends StatelessWidget {
  final String employeeId;

  const GadgetResponsibilityView({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("My Gadgets"),
        backgroundColor: AppColors1.cardBackground,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("gadgets_responsibility")
            .where("employeeId", isEqualTo: employeeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No gadgets assigned",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final data = docs.first.data() as Map<String, dynamic>;
          List gadgets = data["gadgets"] ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gadgets.length,
            itemBuilder: (context, index) {
              return Card(
                color: AppColors1.cardBackground,
                child: ListTile(
                  leading: const Icon(Icons.camera_alt,
                      color: AppColors1.primaryAccent),
                  title: Text(gadgets[index],
                      style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
