import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';
import '../../services/push_notification_service.dart';
import 'package:urban_advertising/Employee/screens/booking_progress_screen.dart';

class EmpSlotRequestsScreen extends StatefulWidget {
  const EmpSlotRequestsScreen({super.key});

  @override
  State<EmpSlotRequestsScreen> createState() => _EmpSlotRequestsScreenState();
}

class _EmpSlotRequestsScreenState extends State<EmpSlotRequestsScreen> {
  final CollectionReference slotRef =
  FirebaseFirestore.instance.collection("slot_request");

  // ----------------------- CONFIRMATION DIALOG ------------------------
  Future<void> showConfirmDialog({
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text("Confirmation",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("Confirm",
                  style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  // ----------------------- UPDATE STATUS ------------------------
  Future<void> updateSlotStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection("slot_request")
          .doc(docId)
          .update({"status": newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Slot $newStatus successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentEmployeeId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Slot Requests",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: slotRef.orderBy("created_at", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No slot requests found.",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final assignedId = data["assigned_employee_id"];

            // SHOW ONLY:
            // 1. Requests assigned to this employee
            // 2. Requests not assigned (just for viewing)
            return assignedId == null || assignedId == currentEmployeeId;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text("No tasks assigned.",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              final status = (data["status"] ?? "pending").toLowerCase();
              final assignedEmployeeId = data["assigned_employee_id"];

              // Check if this employee is assigned
              final isAssignedToMe = assignedEmployeeId == currentEmployeeId;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingProgressScreen(bookingId: docId, data: data),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["customer_name"] ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text("Date: ${data["date"]}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Time: ${data["time"]}",
                          style: const TextStyle(color: Colors.white70)),

                      const SizedBox(height: 6),
                      Text("Service: ${data["service"]}",
                          style: const TextStyle(color: Colors.white70)),

                      if (assignedEmployeeId != null)
                        const Text(
                          "Task Assigned by Admin",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),

                      const SizedBox(height: 12),

                      // -----------------------------
                      // STATUS LABEL
                      // -----------------------------
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == "done"
                              ? Colors.green.withOpacity(0.2)
                              : status == "approved"
                              ? Colors.green.withOpacity(0.2)
                              : status == "rejected"
                              ? Colors.red.withOpacity(0.2)
                              : Colors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == "done"
                                ? Colors.greenAccent
                                : status == "approved"
                                ? Colors.greenAccent
                                : status == "rejected"
                                ? Colors.redAccent
                                : Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ===================================================
                      //      EMPLOYEE BUTTON LOGIC (VERY IMPORTANT)
                      // ===================================================

                      if (isAssignedToMe && status == "approved") ...[
                        // Only show when admin has assigned the task
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showConfirmDialog(
                                    message: "Mark this task as DONE?",
                                    onConfirm: () =>
                                        updateSlotStatus(docId, "done"),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text("Mark Done"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Expanded(
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       showConfirmDialog(
                            //         message: "Reject this assigned task?",
                            //         onConfirm: () =>
                            //             updateSlotStatus(docId, "rejected"),
                            //       );
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.red),
                            //     child: const Text("Reject"),
                            //   ),
                            // ),
                          ],
                        ),
                      ],

                      if (!isAssignedToMe && status == "pending")
                        const Text(
                          "Waiting for Admin Approval",
                          style: TextStyle(color: Colors.white54),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/emp_home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/clients');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/employee_profile');
          }
        },
      ),
    );
  }
}
