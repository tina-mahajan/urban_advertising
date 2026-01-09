import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminReportProblemView extends StatelessWidget {
  const AdminReportProblemView({super.key});

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat("dd MMM yyyy, hh:mm a")
        .format(timestamp.toDate());
  }

  IconData getProblemIcon(String type) {
    switch (type) {
      case "Client Issue":
        return Icons.support_agent;
      case "Location Issue":
        return Icons.location_on;
      case "Equipment Problem":
        return Icons.devices;
      case "Network / Upload Issue":
        return Icons.wifi;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Admin – Problem Reports"),
        backgroundColor: AppColors1.cardBackground,
        centerTitle: true,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("problem_reports")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white70));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No problems reported yet",
                  style: TextStyle(color: Colors.white60)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data =
              docs[index].data() as Map<String, dynamic>;

              final String employeeName =
              (data["employeeName"] ?? "Unknown").toString();

              final String problemType =
              (data["problemType"] ?? "Other").toString();

              final String description =
              (data["description"] ?? "").toString();

              // final String status =
              // (data["status"] ?? "open").toString();

              return Card(
                color: AppColors1.cardBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 6,

                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            AppColors1.primaryAccent.withOpacity(0.2),
                            child: Icon(
                              getProblemIcon(problemType),
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employeeName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  problemType,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          // Chip(
                          //   label: Text(status.toUpperCase()),
                          //   backgroundColor:
                          //   AppColors1.primaryAccent.withOpacity(0.15),
                          //   labelStyle:
                          //   const TextStyle(color: Colors.white70),
                          // )
                        ],
                      ),

                      const Divider(color: Colors.white12),

                      const SizedBox(height: 8),

                      const Text(
                        "Description:",
                        style: TextStyle(color: Colors.white38),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        description,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Reported At: ${formatDate(data["createdAt"])}",
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
