import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingProgressScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> data;

  const BookingProgressScreen({
    super.key,
    required this.bookingId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text("Task Progress"),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("slot_request")
            .doc(bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final booking =
              snapshot.data!.data() as Map<String, dynamic>? ?? data;

          final String status = booking["status"] ?? "pending";
          final String progress =
              booking["progress_status"] ?? "approved";

          // 🔒 BLOCK PENDING (NO UI CHANGE)
          if (status == "pending") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.hourglass_empty,
                      color: Colors.orangeAccent, size: 80),
                  SizedBox(height: 20),
                  Text(
                    "Waiting for admin approval.\nYou cannot start this task yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (status == "rejected") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cancel,
                      color: Colors.redAccent, size: 80),
                  SizedBox(height: 20),
                  Text(
                    "This task was rejected.\nNo progress available.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (status == "done") {
            return _completedView(booking);
          }

          return _progressView(context, booking, progress);
        },
      ),
    );
  }

  // ---------------- BOOKING DETAILS ----------------
  Widget _bookingDetails(Map<String, dynamic> b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          b["customer_name"] ?? "",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Service: ${b['service']}",
            style: const TextStyle(color: Colors.white70)),
        Text("Date: ${b['date']}",
            style: const TextStyle(color: Colors.white70)),
        Text("Time: ${b['time']}",
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 20),
        const Divider(color: Colors.white24),
      ],
    );
  }

  // ---------------- COMPLETED VIEW ----------------
  Widget _completedView(Map<String, dynamic> booking) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bookingDetails(booking),

          _step("Approved", true),
          _line(),
          _step("Shooting", true),
          _line(),
          _step("Editing", true),
          _line(),
          _step("Delivered", true),

          const Spacer(),

          const Text(
            "Task Completed ✔",
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS VIEW ----------------
  Widget _progressView(
      BuildContext context, Map<String, dynamic> booking, String progress) {
    const steps = ["approved", "shooting", "editing", "delivered"];
    final int currentIndex = steps.indexOf(progress);
    final String nextStep =
    currentIndex < steps.length - 1 ? steps[currentIndex + 1] : "delivered";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bookingDetails(booking),

          _step("Approved", currentIndex >= 0),
          _line(),
          _step("Shooting", currentIndex >= 1),
          _line(),
          _step("Editing", currentIndex >= 2),
          _line(),
          _step("Delivered", currentIndex >= 3),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // 🔥 UPDATE PROGRESS
                await FirebaseFirestore.instance
                    .collection("slot_request")
                    .doc(bookingId)
                    .update({
                  "progress_status": nextStep,
                  "updated_at": FieldValue.serverTimestamp(),
                  "last_updated_by": "employee",
                  if (nextStep == "delivered") "status": "done",
                });

                // 🔔 ADMIN NOTIFICATION (WORKING)
                await _notifyAdmin(
                  bookingId: bookingId,
                  customerName: booking["customer_name"] ?? "Customer",
                  service: booking["service"] ?? "Service",
                  progress: nextStep,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Move to ${nextStep.toUpperCase()}",
                style:
                const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- STEP UI ----------------
  Widget _step(String step, bool active) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.radio_button_unchecked,
          color: active ? Colors.greenAccent : Colors.white30,
          size: 30,
        ),
        const SizedBox(width: 12),
        Text(
          step,
          style: TextStyle(
            fontSize: 18,
            color: active ? Colors.greenAccent : Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _line() {
    return Container(
      height: 35,
      width: 3,
      margin: const EdgeInsets.only(left: 13),
      color: Colors.white24,
    );
  }

  // ---------------- ADMIN NOTIFICATION ----------------
  Future<void> _notifyAdmin({
    required String bookingId,
    required String customerName,
    required String service,
    required String progress,
  }) async {
    final adminSnapshot =
    await FirebaseFirestore.instance.collection("admin").get();

    for (var admin in adminSnapshot.docs) {
      final token = admin.data()["fcmToken"];
      if (token == null) continue;

      await FirebaseFirestore.instance
          .collection("push_notifications")
          .add({
        "token": token,
        "title": "Booking Progress Updated",
        "body":
        "Employee updated $customerName's booking ($service) to ${progress.toUpperCase()}",
        "bookingId": bookingId,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
