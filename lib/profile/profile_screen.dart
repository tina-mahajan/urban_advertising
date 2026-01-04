import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../home/subscription_screen.dart';
import '../../widgets/bottom_navbar.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'package:urban_advertising/bookings/booking_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentIndex = 3;

  String name = "";
  String email = "";
  String phone = "";

  int totalBookings = 0;
  int upcomingBookings = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // -------------------------------------------------
  // 🔥 LOAD PROFILE + ACTIVITY (NO NEW COLLECTIONS)
  // -------------------------------------------------
  Future<void> loadProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      String uid = user.uid;

      // CUSTOMER INFO
      final customerDoc = await FirebaseFirestore.instance
          .collection("Customer")
          .doc(uid)
          .get();

      // BOOKINGS (USED FOR ACTIVITY)
      final bookingSnap = await FirebaseFirestore.instance
          .collection("slot_request")
          .where("customerId", isEqualTo: uid)
          .get();

      setState(() {
        if (customerDoc.exists) {
          name = customerDoc["Customer_Name"] ?? "";
          email = customerDoc["Customer_Email"] ?? "";
          phone = customerDoc["Customer_Mobile_Number"] ?? "";
        }

        totalBookings = bookingSnap.docs.length;
        upcomingBookings = bookingSnap.docs
            .where((doc) => doc["status"] == "upcoming")
            .length;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  void onTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/slot_booking');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/subscription');
        break;
      case 3:
        break;
    }
  }

  // -------------------------------------------------
  // UI
  // -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            _subscriptionCard(context),
            const SizedBox(height: 16),
            _activityCard(),
            const SizedBox(height: 16),
            _downloadReport(),
            const SizedBox(height: 16),
            _contentSection(context),
          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(currentIndex: currentIndex, onTap: onTap),
    );
  }

  // -------------------------------------------------
  // PROFILE CARD
  // -------------------------------------------------
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxStyle(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(phone.isEmpty ? "No Phone" : phone,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditProfileScreen(name: name, email: email, phone: phone),
                ),
              );
              loadProfile();
            },
          )
        ],
      ),
    );
  }

  // -------------------------------------------------
  // SUBSCRIPTION CARD (SAFE FALLBACK)
  // -------------------------------------------------
  Widget _subscriptionCard(BuildContext context) {
    return _buildCard(
      title: "Subscription Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("No Active Plan",
              style: TextStyle(color: Colors.white)),
          const Text("Valid Till: -",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Upcoming Bookings: $upcomingBookings",
                  style: const TextStyle(color: Colors.white70)),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor:
                  MaterialStatePropertyAll<Color>(Colors.white),
                  foregroundColor:
                  MaterialStatePropertyAll<Color>(Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen()),
                  );
                },
                child: const Text("Renew Plan"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // -------------------------------------------------
  // ACTIVITY CARD (REAL DATA)
  // -------------------------------------------------
  Widget _activityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Total Bookings: $totalBookings',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Upcoming Bookings: $upcomingBookings',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // DOWNLOAD REPORT (PLACEHOLDER – SAFE)
  // -------------------------------------------------
  Widget _downloadReport() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Monthly report will be available soon"),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _boxStyle(),
        child: const Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.white70),
            SizedBox(width: 8),
            Text("Download your Instagram Monthly Report",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // MY CONTENT
  // -------------------------------------------------
  Widget _contentSection(BuildContext context) {
    return _buildCard(
      title: "My Content",
      child: Column(
        children: [
          _tile(Icons.video_collection_outlined, "My Videos"),
          _tile(Icons.history, "Bookings History",
              screen: const BookingHistoryScreen()),
          _tile(Icons.favorite_border, "Saved Items"),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // HELPERS
  // -------------------------------------------------
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String text, {Widget? screen}) {
    return InkWell(
      onTap: () {
        if (screen != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => screen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$text feature coming soon")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
