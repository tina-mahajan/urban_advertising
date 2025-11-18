import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF141414);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFF5A00FF);
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

  List<dynamic> upcoming = [];
  List<dynamic> pending = [];
  List<dynamic> history = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("http://10.0.2.2:4000/api/bookings/my-bookings"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("BOOKING HISTORY = ${response.body}");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)["bookings"];

      setState(() {
        upcoming =
            data.where((b) => b['status'] == "confirmed" || b['status'] == "assigned").toList();
        pending = data.where((b) => b['status'] == "pending").toList();
        history = data.where((b) => b['status'] == "completed" || b['status'] == "cancelled").toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "confirmed":
      case "assigned":
        return Colors.lightGreenAccent;
      case "pending":
        return Colors.orangeAccent;
      case "completed":
        return AppColors.primaryAccent;
      case "cancelled":
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  Color _getStatusBackground(Color color) => color.withAlpha(38);

  Widget bookingCard({
    required String date,
    required String time,
    required String name,
    required String phone,
    required String statusText,
    required Color statusColor,
  }) {
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
            Text("Date: $date", style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 6),
            Text("Time: $time", style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 6),
            Text("Videographer: $name",
                style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
            const SizedBox(height: 6),
            Text("Phone: $phone",
                style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusBackground(statusColor),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
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

  Widget historyCard({
    required String date,
    required String time,
    required String statusText,
    required Color statusColor,
  }) {
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
            Text("Date: $date", style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 6),
            Text("Time: $time", style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusBackground(statusColor),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
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

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : TabBarView(
        controller: _tabController,
        children: [
          // UPCOMING
          ListView(
            children: upcoming.map((b) {
              return bookingCard(
                date: b["date"],
                time: b["slot_time"],
                name: b["assigned_employee"] ?? "Not Assigned",
                phone: "N/A",
                statusText: b["status"],
                statusColor: _statusColor(b["status"]),
              );
            }).toList(),
          ),

          // PENDING
          ListView(
            children: pending.map((b) {
              return bookingCard(
                date: b["date"],
                time: b["slot_time"],
                name: "Waiting...",
                phone: "N/A",
                statusText: "Awaiting Confirmation",
                statusColor: Colors.orangeAccent,
              );
            }).toList(),
          ),

          // HISTORY
          ListView(
            children: history.map((b) {
              return historyCard(
                date: b["date"],
                time: b["slot_time"],
                statusText: b["status"],
                statusColor: _statusColor(b["status"]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
