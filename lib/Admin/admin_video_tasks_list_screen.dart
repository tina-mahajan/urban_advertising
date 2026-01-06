import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminVideoTasksListScreen extends StatelessWidget {
  final String status;
  final String title;

  const AdminVideoTasksListScreen({
    super.key,
    required this.status,
    required this.title,
  });

  Color _color(String s) =>
      s == "pending" ? Colors.orange :
      s == "in_progress" ? Colors.blue :
      Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.cardBackground,
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("video_tasks")
            .where("status", isEqualTo: status)
            .snapshots(),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());

          if (s.data!.docs.isEmpty) {
            return const Center(child: Text("No video tasks found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: s.data!.docs.length,
            itemBuilder: (c, i) {
              final d = s.data!.docs[i].data() as Map<String, dynamic>;

              return _TaskCard(
                title: d["video_title"],
                client: d["client_name"],
                assigned: d["assigned_employee_name"],
                date: d["expected_delivery"],
                status: d["status"],
                color: _color(d["status"]),
              );
            },
          );
        },
      ),
    );
  }

}
class _TaskCard extends StatelessWidget {
  final String title;
  final String client;
  final String assigned;
  final Timestamp date;
  final String status;
  final Color color;

  const _TaskCard({
    required this.title,
    required this.client,
    required this.assigned,
    required this.date,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title ?? "Untitled Task",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "Client: ${client ?? "-"}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Assigned To: ${assigned ?? "-"}",
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            "Delivery Date: ${DateFormat("dd MMM yyyy").format(date.toDate())}",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

