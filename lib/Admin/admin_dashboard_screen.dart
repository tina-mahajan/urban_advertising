import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';
import 'admin_add_order_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // ===================== BOOKINGS STREAMS =====================

  Stream<QuerySnapshot> _allBookingsStream() {
    return FirebaseFirestore.instance
        .collection('slot_request')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<int> _countByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('slot_request')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
        return Colors.orangeAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'done':
        return AppColors1.primaryAccent;
      default:
        return Colors.white;
    }
  }

  // =========================== UI =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.cardBackground,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminAddOrderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: "Add Offline Order",
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ---------- STATS ROW ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    label: "Upcoming",
                    status: "approved",
                    stream: _countByStatus("approved"),
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    label: "Pending",
                    status: "pending",
                    stream: _countByStatus("pending"),
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    label: "Completed",
                    status: "done",
                    stream: _countByStatus("done"),
                    color: AppColors1.primaryAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "All Bookings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---------- BOOKINGS LIST ----------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _allBookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No bookings found.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = (data["status"] ?? "pending").toString();
                    final isPending = status.toLowerCase() == "pending";

                    return Card(
                      color: AppColors1.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: name + status chip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data["customer_name"] ?? "Unknown",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(
                              "Service: ${data["service"] ?? "-"}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              "Date: ${data["date"] ?? "-"}   |   Time: ${data["time"] ?? "-"}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              "Place: ${data["location"] ?? data["place"] ?? "-"}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Source: ${(data["source"] ?? "online").toString().toUpperCase()}",
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 10),

                            // Assigned employee info
                            if (data["assigned_employee_name"] != null)
                              Text(
                                "Assigned to: ${data["assigned_employee_name"]}",
                                style: const TextStyle(
                                    color: Colors.greenAccent, fontSize: 13),
                              ),

                            const SizedBox(height: 10),

                            // ACTION BUTTONS
                            Row(
                              children: [
                                if (isPending)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _showAssignEmployeeSheet(
                                            context, doc.id, data);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side:
                                        const BorderSide(color: Colors.blueAccent),
                                      ),
                                      child: const Text(
                                        "Assign",
                                        style:
                                        TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ),

                                if (isPending) const SizedBox(width: 8),

                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _updateStatus(context, doc.id, "approved");
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.greenAccent),
                                    ),
                                    child: const Text(
                                      "Approve",
                                      style:
                                      TextStyle(color: Colors.greenAccent),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _updateStatus(context, doc.id, "rejected");
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.redAccent),
                                    ),
                                    child: const Text(
                                      "Reject",
                                      style:
                                      TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Mark as done (for approved)
                            if (status == "approved")
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    _updateStatus(context, doc.id, "done");
                                  },
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Mark as Done",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================== UPDATE STATUS IN FIRESTORE ==================

  Future<void> _updateStatus(
      BuildContext context, String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection("slot_request")
          .doc(docId)
          .update({"status": newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to $newStatus"),
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

  // ================= ASSIGN EMPLOYEE BOTTOM SHEET =================

  void _showAssignEmployeeSheet(
      BuildContext context, String bookingId, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors1.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? selectedEmployeeId;
        String? selectedEmployeeName;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assign Employee",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("employee")
                    .where("role", isEqualTo: "employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Error loading employees: ${snapshot.error}",
                        style:
                        const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    );
                  }

                  final employees = snapshot.data?.docs ?? [];

                  if (employees.isEmpty) {
                    return const Text(
                      "No employees found.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    );
                  }

                  return StatefulBuilder(
                    builder: (context, setStateSB) {
                      return DropdownButtonFormField<String>(
                        dropdownColor: AppColors1.cardBackground, // background of the dropdown list
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08), // input box color
                          labelText: "Select Employee",
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors1.primaryAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        iconEnabledColor: Colors.white, // dropdown arrow color

                        style: const TextStyle(
                          color: Colors.white,  // selected text color
                          fontSize: 15,
                        ),

                        items: employees.map((e) {
                          final empData = e.data() as Map<String, dynamic>;
                          final name = empData["name"] ?? "Unnamed";
                          return DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white), // dropdown item color
                            ),
                          );
                        }).toList(),

                        onChanged: (val) {
                          if (val == null) return;

                          final empDoc = employees.firstWhere((d) => d.id == val);
                          final empData = empDoc.data() as Map<String, dynamic>;

                          setStateSB(() {
                            selectedEmployeeId = val;
                            selectedEmployeeName = empData["name"] ?? "Employee";
                          });
                        },

                        value: selectedEmployeeId,
                      );
                    },
                  );


                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    if (selectedEmployeeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select an employee"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection("slot_request")
                        .doc(bookingId)
                        .update({
                      "assigned_employee_id": selectedEmployeeId,
                      "assigned_employee_name": selectedEmployeeName,
                      "status": "approved",
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Employee assigned successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Assign"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== SMALL STATUS CARD WIDGET ====================

class _StatusCard extends StatelessWidget {
  final String label;
  final String status;
  final Stream<int> stream;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.status,
    required this.stream,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors1.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$count",
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
