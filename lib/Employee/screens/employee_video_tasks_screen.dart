import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:intl/intl.dart';

class EmployeeVideoTasksScreen extends StatelessWidget {
  final String myUid;

  const EmployeeVideoTasksScreen({super.key, required this.myUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(title: const Text("Video Tasks")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("video_tasks")
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: s.data!.docs.length,
            itemBuilder: (c, i) {
              final d = s.data!.docs[i].data() as Map<String, dynamic>;
              final bool isMine = d["assigned_employee_id"] == myUid;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors1.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d["video_title"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),

                    const SizedBox(height: 6),
                    Text("Client: ${d["client_name"]}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Assigned To: ${d["assigned_employee_name"]}",
                        style: const TextStyle(color: Colors.white70)),
                    Text(
                      "Delivery: ${DateFormat("dd MMM yyyy").format(d["expected_delivery"].toDate())}",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    if (isMine && d["status"] == "pending")
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("video_tasks")
                              .doc(s.data!.docs[i].id)
                              .update({"status": "in_progress"});
                        },
                        child: const Text("Start Work"),
                      ),

                    if (isMine && d["status"] == "in_progress")
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("video_tasks")
                              .doc(s.data!.docs[i].id)
                              .update({"status": "done"});
                        },
                        child: const Text("Mark as Done"),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

