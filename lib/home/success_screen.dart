import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/home/home_screen.dart';
import 'package:urban_advertising/home/receipt_screen.dart';
class SuccessScreen extends StatelessWidget {
  final String planName;
  final String planPrice;
  final String userName;
  final String paymentDate;

  const SuccessScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.userName,
    required this.paymentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Payment Successful',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Success Icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(30),
              child: const Icon(Icons.check, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 24),

            // ✅ Payment Text
            const Text(
              "Payment Successful!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Description
            Text(
              "You are now subscribed to the $planName plan.\nYour payment of $planPrice was successful.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),

            const SizedBox(height: 40),

            // ✅ Go to Home
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                );
              },
              child: const Text(
                "Go To Home",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ View Receipt
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptScreen(
                      userName: "Sangam Bhosari",
                      planName: "Premium Plan",
                      planPrice: "₹999/month",
                      paymentDate: "09 Nov 2025",
                    ),
                  ),
                );
              },
              child: const Text(
                "View Receipt",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
