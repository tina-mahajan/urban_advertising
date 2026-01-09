import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';

class GadgetResponsibilityView extends StatelessWidget {
  const GadgetResponsibilityView({super.key});

  // ===== DATE FORMATTER =====
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat("dd MMM yyyy, hh:mm a")
        .format(timestamp.toDate());
  }

  // ===== CHIP COLOR USING APPLICATION THEME =====
  Color chipColor() {
    return AppColors1.primaryAccent.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,

      appBar: AppBar(
        title: const Text(
          "Team Gadget Responsibility",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors1.cardBackground,
        centerTitle: true,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("gadgets_responsibility")
            .orderBy("assignedAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No gadgets assigned yet",
                style: TextStyle(color: Colors.white60, fontSize: 18),
              ),
            );
          }

          // ===== GROUP BY EMPLOYEE TO PREVENT DUPLICATE TILES =====
          Map<String, Map<String, dynamic>> grouped = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            String empName = (data["employeeName"] ?? "Employee").toString();
            String empId = (data["employeeId"] ?? "").toString();

            List<String> gadgets =
            List<String>.from(data["gadgets"] ?? []);

            Timestamp? assignedAt = data["assignedAt"];

            // APPEND GADGETS IF ALREADY EXISTS
            if (grouped.containsKey(empId)) {
              List<String> existingGadgets =
              List<String>.from(grouped[empId]!["gadgets"]);

              grouped[empId]!["gadgets"] =
                  {...existingGadgets, ...existingGadgets}.toSet().toList();

              grouped[empId]!["assignedAt"] = assignedAt;
            } else {
              grouped[empId] = {
                "employeeName": empName,
                "gadgets": gadgets,
                "assignedAt": assignedAt
              };
            }
          }

          return ListView(
            padding: const EdgeInsets.all(18),

            children: grouped.entries.map((entry) {

              final emp = entry.value;

              final String employeeName =
                  emp["employeeName"] ?? "";

              final List<String> gadgets =
              List<String>.from(emp["gadgets"] ?? []);

              final Timestamp? assignedAt =
              emp["assignedAt"];

              return Card(
                color: AppColors1.cardBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 6,

                child: ExpansionTile(
                  iconColor: AppColors1.primaryAccent,
                  collapsedIconColor: Colors.white38,

                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                        AppColors1.primaryAccent.withOpacity(0.2),
                        child: const Icon(Icons.person,
                            color: Colors.white70),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          employeeName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Assigned Gadgets:",
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,

                            children: gadgets.map((g) {
                              return Chip(
                                avatar: Icon(Icons.devices_other,
                                    color: AppColors1.secondaryAccent,
                                    size: 20),

                                label: Text(
                                  g,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),

                                backgroundColor: chipColor(),
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Assigned At: ${formatDate(assignedAt)}",
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
