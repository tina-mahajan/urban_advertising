import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const AdminBookingDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<AdminBookingDetailsScreen> createState() =>
      _AdminBookingDetailsScreenState();
}

class _AdminBookingDetailsScreenState extends State<AdminBookingDetailsScreen> {
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _setInitialStep();
  }

  void _setInitialStep() {
    String status = widget.data["progress_status"] ?? widget.data["status"] ?? "approved";

    if (status == "approved") currentStep = 0;
    if (status == "shooting") currentStep = 1;
    if (status == "editing") currentStep = 2;
    if (status == "delivered") currentStep = 3;

    setState(() {});
  }

  Widget _bookingDetails(Map<String, dynamic> b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          b["customer_name"] ?? "Unknown",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text("Service: ${b['service']}", style: const TextStyle(color: Colors.white70)),
        Text("Date: ${b['date']}", style: const TextStyle(color: Colors.white70)),
        Text("Time: ${b['time']}", style: const TextStyle(color: Colors.white70)),
        if (b["location"] != null)
          Text("Location: ${b['location']}", style: const TextStyle(color: Colors.white70)),
        if (b["assigned_employee_name"] != null)
          Text("Assigned Employee: ${b['assigned_employee_name']}",
              style: const TextStyle(color: Colors.greenAccent)),
        const SizedBox(height: 22),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bookingDetails(booking),

            Expanded(
              child: Stepper(
                currentStep: currentStep,
                physics: const NeverScrollableScrollPhysics(),
                steps: const [
                  Step(
                      title: Text("Approved", style: TextStyle(color: Colors.white)),
                      content: SizedBox(),
                      isActive: true),
                  Step(
                      title: Text("Shooting", style: TextStyle(color: Colors.white)),
                      content: SizedBox(),
                      isActive: true),
                  Step(
                      title: Text("Editing", style: TextStyle(color: Colors.white)),
                      content: SizedBox(),
                      isActive: true),
                  Step(
                      title: Text("Delivered", style: TextStyle(color: Colors.white)),
                      content: SizedBox(),
                      isActive: true),
                ],
                controlsBuilder: (context, details) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
