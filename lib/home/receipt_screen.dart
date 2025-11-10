import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class ReceiptScreen extends StatelessWidget {
  final String userName;
  final String planName;
  final String planPrice;
  final String paymentDate;

  const ReceiptScreen({
    super.key,
    required this.userName,
    required this.planName,
    required this.planPrice,
    required this.paymentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Receipt",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30), // <-- added padding from top

            // Logo
            Center(
              child: Image.asset(
                'assets/white.png',
                height: 100, // adjust as needed
              ),
            ),

            const SizedBox(height: 20),

            _buildRow("Customer Name:", userName),
            const Divider(color: Colors.white24),
            _buildRow("Plan Name:", planName),
            const Divider(color: Colors.white24),
            _buildRow("Amount Paid:", planPrice),
            const Divider(color: Colors.white24),
            _buildRow("Payment Date:", paymentDate),
            const Divider(color: Colors.white24),

            const Spacer(),

            // Done button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for rows
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            value.isNotEmpty ? value : "-",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
