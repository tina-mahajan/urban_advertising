import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusBackground(Color color) {

    return color.withAlpha(38);
  }

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
            Text("Videographer: $name", style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
            const SizedBox(height: 6),
            Text("Phone: $phone", style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
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
    const Color confirmedColor = Colors.lightGreenAccent;
    const Color pendingColor = Colors.orangeAccent;
    const Color completedColor = AppColors.primaryAccent;
    const Color cancelledColor = Colors.redAccent;

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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming
          ListView(
            children: [
              bookingCard(
                date: "10 Nov 2025",
                time: "10:00 AM",
                name: "Anurag Mate",
                phone: "+91 7276188376",
                statusText: "Confirmed",
                statusColor: confirmedColor,
              ),
              bookingCard(
                date: "12 Nov 2025",
                time: "02:30 PM",
                name: "Jayesh Chaudhari",
                phone: "+91 7276188376",
                statusText: "Confirmed",
                statusColor: confirmedColor,
              ),
            ],
          ),

          // Pending
          ListView(
            children: [
              bookingCard(
                date: "15 Nov 2025",
                time: "11:00 AM",
                name: "Jayesh Chaudhari",
                phone: "+91 9871112233",
                statusText: "Awaiting Confirmation",
                statusColor: pendingColor,
              ),
            ],
          ),

          // History
          ListView(
            children: [
              historyCard(
                date: "03 Nov 2025",
                time: "03:00 PM",
                statusText: "Completed",
                statusColor: completedColor,
              ),
              historyCard(
                date: "01 Nov 2025",
                time: "09:30 AM",
                statusText: "Cancelled",
                statusColor: cancelledColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}