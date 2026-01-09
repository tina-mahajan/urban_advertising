import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';

class EmployeeVideoTasksTabScreen extends StatelessWidget {
  final String myUid;

  const EmployeeVideoTasksTabScreen({
    super.key,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors1.darkBackground,
        appBar: AppBar(
          title: const Text("Video Task Screen"),
          backgroundColor: AppColors1.cardBackground,
          bottom: const TabBar(
            indicatorColor: Colors.orangeAccent,
            labelColor: Colors.orangeAccent,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "In-Progress"),
              Tab(text: "Done"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TaskList(status: "pending", myUid: myUid),
            _TaskList(status: "in_progress", myUid: myUid),
            _TaskList(status: "done", myUid: myUid),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   TASK LIST WIDGET (REUSED FOR ALL 3 TABS)
============================================================ */

class _TaskList extends StatelessWidget {
  final String status;
  final String myUid;

  const _TaskList({
    required this.status,
    required this.myUid,
  });

  // ---------- STATUS COLOR ----------
  Color _statusColor(String s) {
    switch (s) {
      case "pending":
        return Colors.orangeAccent;
      case "in_progress":
        return Colors.blueAccent;
      case "done":
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  // ---------- PRIORITY ROW ----------
  Widget _priorityRow(String priority) {
    final bool isUrgent = priority.toLowerCase() == "urgent";

    return Row(
      children: [
        Icon(
          isUrgent ? Icons.warning_amber_rounded : Icons.check_circle,
          size: 14,
          color: isUrgent ? Colors.redAccent : Colors.greenAccent,
        ),
        const SizedBox(width: 6),
        Text(
          priority.toUpperCase(),
          style: TextStyle(
            color: isUrgent ? Colors.redAccent : Colors.greenAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("video_tasks")
          .where("status", isEqualTo: status)
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No video tasks found",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final bool isMyTask =
                data["assigned_employee_id"] == myUid;

            final String title =
                data["video_title"] ?? "Untitled Task";

            final String client =
                data["client_name"] ?? "-";

            final String assigned =
                data["assigned_employee_name"] ?? "-";

            final String priority =
                data["priority"] ?? "Normal";

            final Timestamp? deliveryTs =
            data["expected_delivery"];

            final String deliveryDate = deliveryTs == null
                ? "-"
                : DateFormat("dd MMM yyyy")
                .format(deliveryTs.toDate());

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
                  // -------- TITLE + STATUS --------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                          _statusColor(status).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
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

                  // -------- PRIORITY --------
                  _priorityRow(priority),

                  const SizedBox(height: 10),

                  Text("Client: $client",
                      style:
                      const TextStyle(color: Colors.white70)),
                  Text("Assigned To: $assigned",
                      style:
                      const TextStyle(color: Colors.white70)),
                  Text("Delivery Date: $deliveryDate",
                      style:
                      const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 12),

                  // -------- ACTION BUTTONS --------
                  if (isMyTask && status == "pending")
                    ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("video_tasks")
                            .doc(doc.id)
                            .update({"status": "in_progress"});
                      },
                      child: const Text("Start Work"),
                    ),

                  if (isMyTask && status == "in_progress")
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("video_tasks")
                            .doc(doc.id)
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
    );
  }
}
