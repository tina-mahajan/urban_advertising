import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen> {
  bool isLoading = true;

  int totalBookings = 0;
  int completedBookings = 0;
  int pendingBookings = 0;

  double totalRevenue = 0;
  double monthlyRevenue = 0;
  double yearlyRevenue = 0;

  @override
  void initState() {
    super.initState();
    loadRevenue();
  }

  // --------------------------------------------------
  // 🔥 LOAD REVENUE (TOTAL + MONTHLY + YEARLY)
  // --------------------------------------------------
  Future<void> loadRevenue() async {
    try {
      // 1️⃣ Load all services → Map by NAME
      final serviceSnapshot =
      await FirebaseFirestore.instance.collection("services").get();

      Map<String, double> servicePriceMap = {};
      for (var doc in serviceSnapshot.docs) {
        final data = doc.data();
        final String name = data["name"] ?? "";
        final double price = (data["price"] ?? 0).toDouble();
        servicePriceMap[name] = price;
      }

      // 2️⃣ Load all slot requests
      final bookingSnapshot =
      await FirebaseFirestore.instance.collection("slot_request").get();

      final now = DateTime.now();

      double total = 0;
      double monthly = 0;
      double yearly = 0;

      int completed = 0;
      int pending = 0;
      int totalCount = 0;

      for (var doc in bookingSnapshot.docs) {
        totalCount++;

        final data = doc.data();
        final String status = data["status"] ?? "";
        final String serviceName = data["service"] ?? "";

        if (status != "done") {
          pending++;
          continue;
        }

        completed++;

        final price = servicePriceMap[serviceName] ?? 0;
        total += price;

        // 📅 DATE CHECK
        final Timestamp? ts = data["created_at"];
        if (ts != null) {
          final date = ts.toDate();

          // Monthly
          if (date.month == now.month && date.year == now.year) {
            monthly += price;
          }

          // Yearly
          if (date.year == now.year) {
            yearly += price;
          }
        }
      }

      setState(() {
        totalBookings = totalCount;
        completedBookings = completed;
        pendingBookings = pending;
        totalRevenue = total;
        monthlyRevenue = monthly;
        yearlyRevenue = yearly;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("REVENUE ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Revenue Overview"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card("Total Bookings", totalBookings),
            _card("Completed Bookings", completedBookings),
            _card("Pending Bookings", pendingBookings),

            const SizedBox(height: 12),

            _card(
              "Total Revenue",
              "₹ ${totalRevenue.toStringAsFixed(0)}",
            ),
            _card(
              "This Month Revenue",
              "₹ ${monthlyRevenue.toStringAsFixed(0)}",
            ),
            _card(
              "This Year Revenue",
              "₹ ${yearlyRevenue.toStringAsFixed(0)}",
            ),

            const SizedBox(height: 12),
            const Text(
              "* Revenue is calculated from completed bookings using service prices.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CARD WIDGET
  // --------------------------------------------------
  Widget _card(String title, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
