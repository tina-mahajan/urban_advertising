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
                child: CircularProgressIndicator(color: Colors.white));
          }

          final booking =
              snapshot.data!.data() as Map<String, dynamic>? ?? data;

          String status = booking["status"] ?? "pending";
          String progress = booking["progress_status"] ?? "approved";

          // 🔥 AUTO UPDATE STATUS WHEN PROGRESS COMPLETES
          if (progress == "delivered" && status != "done") {
            FirebaseFirestore.instance
                .collection("slot_request")
                .doc(bookingId)
                .update({"status": "done"});
          }

          if (status == "rejected") {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bookingDetails(booking),
                    const SizedBox(height: 40),
                    const Icon(Icons.cancel,
                        color: Colors.redAccent, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      "This task was rejected.\nNo progress available.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }

          if (status == "done" || progress == "delivered") {
            return _completedView(booking);
          }

          return _progressView(booking, progress);
        },
      ),
    );
  }

  // ---------------- Booking Details ----------------
  Widget _bookingDetails(Map<String, dynamic> b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          b["customer_name"] ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text("Service: ${b['service']}",
            style: const TextStyle(color: Colors.white70)),
        Text("Date: ${b['date']}",
            style: const TextStyle(color: Colors.white70)),
        Text("Time: ${b['time']}",
            style: const TextStyle(color: Colors.white70)),
        if (b["assigned_employee_name"] != null)
          Text("Assigned Employee: ${b['assigned_employee_name']}",
              style: const TextStyle(color: Colors.greenAccent)),
        const SizedBox(height: 20),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),
      ],
    );
  }

  // ---------------- Completed View ----------------
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------- Active Progress View ----------------
  Widget _progressView(Map<String, dynamic> booking, String progress) {
    const steps = ["approved", "shooting", "editing", "delivered"];
    int currentIndex = steps.indexOf(progress);
    String nextStep = currentIndex < 3 ? steps[currentIndex + 1] : "delivered";

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
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("slot_request")
                    .doc(bookingId)
                    .update({"progress_status": nextStep});
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

  // ---------------- Step ----------------
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
}
