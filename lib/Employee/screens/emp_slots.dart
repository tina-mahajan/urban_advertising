import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';


class EmpSlotRequestsScreen extends StatefulWidget {
  const EmpSlotRequestsScreen({super.key});

  @override
  State<EmpSlotRequestsScreen> createState() => _EmpSlotRequestsScreenState();
}

class _EmpSlotRequestsScreenState extends State<EmpSlotRequestsScreen> {
  Future<void> showConfirmDialog({
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            "Confirmation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
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

  final CollectionReference slotRef =
  FirebaseFirestore.instance.collection("slot_request");

  //===============================
  // UPDATE SLOT STATUS
  //===============================
  Future<void> updateSlotStatus(String docId, String newStatus) async {
    try {
      await slotRef.doc(docId).update({"status": newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Slot $newStatus successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Slot Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: slotRef.orderBy("created_at", descending: true).snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No slot requests found.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Container(
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
                    // CUSTOMER NAME
                    Text(
                      data["customer_name"] ?? "Unknown",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // DATE + TIME
                    Text(
                      "Date: ${data["date"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Time: ${data["time"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),

                    // SERVICE
                    Text(
                      "Service: ${data["service"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    // Message
                    if (data["message"] != null && data["message"] != "")
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Message: ${data["message"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // STATUS BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: data["status"] == "approved"
                            ? Colors.green.withOpacity(0.2)
                            : data["status"] == "rejected"
                            ? Colors.red.withOpacity(0.2)
                            : Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data["status"].toString().toUpperCase(),
                        style: TextStyle(
                          color: data["status"] == "approved"
                              ? Colors.greenAccent
                              : data["status"] == "rejected"
                              ? Colors.redAccent
                              : Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ACTION BUTTONS (ONLY IF STATUS IS PENDING)
                    // ACTION BUTTONS (ONLY IF STATUS IS PENDING)
                    if (data["status"].toString().toLowerCase() == "pending")
                      Row(
                        children: [
                          // APPROVE BUTTON
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showConfirmDialog(
                                  message: "Are you sure you want to approve this slot?",
                                  onConfirm: () => updateSlotStatus(docId, "approved"),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008043), // green
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Approve",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // REJECT BUTTON
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showConfirmDialog(
                                  message: "Are you sure you want to reject this slot?",
                                  onConfirm: () => updateSlotStatus(docId, "rejected"),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF0000), // red
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "Reject",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,   // <-- set index where Slot tab should be
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/emp_home');
          } else if (index == 1) {
            // already on Slot page
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
