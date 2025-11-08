import 'package:flutter/material.dart';

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

  Widget bookingCard({
    required String date,
    required String time,
    required String name,
    required String phone,
    required String statusText,
    required Color statusColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $date", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("Time: $time", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("Videographer: $name", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("Phone: $phone", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
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
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $date", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("Time: $time", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
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
                name: "Rohit Sharma",
                phone: "+91 9876543210",
                statusText: "Confirmed",
                statusColor: Colors.green,
              ),
              bookingCard(
                date: "12 Nov 2025",
                time: "02:30 PM",
                name: "Anjali Verma",
                phone: "+91 9998887776",
                statusText: "Confirmed",
                statusColor: Colors.green,
              ),
            ],
          ),

          // Pending
          ListView(
            children: [
              bookingCard(
                date: "15 Nov 2025",
                time: "11:00 AM",
                name: "Ramesh Kumar",
                phone: "+91 9871112233",
                statusText: "Awaiting Confirmation",
                statusColor: Colors.blue,
              ),
            ],
          ),

          // History
          ListView(
            children: [
              historyCard(date: "03 Nov 2025", time: "03:00 PM"),
              historyCard(date: "01 Nov 2025", time: "09:30 AM"),
            ],
          ),
        ],
      ),
    );
  }
}
