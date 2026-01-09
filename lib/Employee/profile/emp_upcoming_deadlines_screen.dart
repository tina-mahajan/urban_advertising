import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class EmployeeUpcomingDeadlinesScreen extends StatelessWidget {
  final String employeeUid;

  const EmployeeUpcomingDeadlinesScreen({
    super.key,
    required this.employeeUid,
  });

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orangeAccent;
      case "in_progress":
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Timestamp now = Timestamp.now();

    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Upcoming Deadlines"),
        backgroundColor: AppColors1.darkBackground,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("video_tasks")
            .where("assigned_employee_id", isEqualTo: employeeUid)
            .where("status", whereIn: ["pending", "in_progress"])
            .where("expected_delivery", isGreaterThanOrEqualTo: now)
            .orderBy("expected_delivery")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors1.primaryAccent,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No upcoming deadlines 🎉",
                style: TextStyle(
                  color: AppColors1.secondaryText,
                  fontSize: 15,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String title =
                  data["video_title"] ?? "Untitled Task";
              final String status =
                  data["status"] ?? "pending";

              final Timestamp deliveryTs =
              data["expected_delivery"];
              final DateTime deliveryDate =
              deliveryTs.toDate();

              final String formattedDate =
              DateFormat("dd MMM yyyy").format(deliveryDate);

              final int daysLeft =
                  deliveryDate.difference(DateTime.now()).inDays;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors1.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _statusColor(status),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + STATUS
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors1.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status)
                                .withOpacity(0.25),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Delivery: $formattedDate",
                      style: const TextStyle(
                        color: AppColors1.secondaryText,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      daysLeft == 0
                          ? "Due Today"
                          : "$daysLeft day(s) left",
                      style: TextStyle(
                        color: daysLeft <= 1
                            ? Colors.redAccent
                            : AppColors1.success,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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
