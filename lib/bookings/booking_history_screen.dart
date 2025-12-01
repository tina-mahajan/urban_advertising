import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF141414);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFF8C00FF);
  static const Color secondaryText = Colors.white70;
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.greenAccent;
      case "pending":
        return Colors.orangeAccent;
      case "done":
        return AppColors.primaryAccent;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  Color _getStatusBackground(Color color) => color.withOpacity(0.15);

  Widget bookingCard({
    required Map<String, dynamic> data,
  }) {
    String status = data["status"] ?? "pending";

    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${data["date"]}", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            Text("Time: ${data["time"]}", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            Text("Service: ${data["service"]}",
                style: const TextStyle(color: AppColors.secondaryText)),
            const SizedBox(height: 8),

            // STATUS BADGE
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusBackground(_statusColor(status)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  status.toUpperCase(),
                  style:
                  TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STREAM FOR FIREBASE BOOKINGS
  Stream<QuerySnapshot> getBookingsStream() {
    return FirebaseFirestore.instance
        .collection("slot_request")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Bookings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primaryAccent,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Pending"),
            Tab(text: "History"),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getBookingsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final docs = snapshot.data!.docs;

          final upcoming = docs.where((d) =>
          d["status"] == "approved").toList();

          final pending = docs.where((d) =>
          d["status"] == "pending").toList();

          final history = docs.where((d) =>
          d["status"] == "done" || d["status"] == "rejected").toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(upcoming),
              _buildList(pending),
              _buildList(history),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text(
          "No records found.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      children: docs.map((d) {
        return bookingCard(data: d.data());
      }).toList(),
    );
  }
}
