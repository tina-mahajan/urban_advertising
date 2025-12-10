//slot booking

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/push_notification_service.dart';

// DARK THEME COLORS
class AppColors {
  static const Color darkBackground = Color(0xFF141414);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFF8C00FF);
  static const Color nav = Color(0xFF8C00FF);
  static const Color secondaryText = Colors.white70;
}

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  String? selectedSlot;
  DateTime selectedDate = DateTime.now();

  final List<String> slots = [
    '10:00AM - 12:00PM',
    '01:00PM - 03:00PM',
    '04:00PM - 06:00PM',
    '07:00PM - 09:00PM',
  ];

  List<DateTime> get dates {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Book a Slot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // 🔥 WHOLE PAGE SCROLLS
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔹 Plan Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Plan: Standard plan (15 Videos)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "You’ve posted 12 videos so far",
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Available Slots',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),

              // 📅 Date Selector
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final isSelected = date.day == selectedDate.day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                          selectedSlot = null;
                        });
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd').format(date),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Slot Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: List.generate(slots.length, (index) {
                    final slot = slots[index];
                    final isSelected = slot == selectedSlot;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : Colors.grey.shade800,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => selectedSlot = slot),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  slot,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                )
                              ],
                            ),
                          ),

                          if (isSelected)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(top: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Selected Slot Summary",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),

                                  Text(
                                    "Date:  ${DateFormat('dd MMM').format(selectedDate)}",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    "Time:  $slot",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const Text(
                                    "Duration:  2 Hours",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: selectedSlot == null
                        ? null
                        : () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        String? uid = prefs.getString("uid");

                        if (uid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Login required"),
                                backgroundColor: Colors.redAccent),
                          );
                          return;
                        }

                        // ---------------------------------------------
                        // 🔍 CHECK IF SLOT ALREADY BOOKED
                        // ---------------------------------------------
                        String selectedDateStr =
                        DateFormat("dd MMM yyyy").format(selectedDate);

                        QuerySnapshot existingSlot =
                        await FirebaseFirestore.instance
                            .collection("slot_request")
                            .where("date",
                            isEqualTo: selectedDateStr)
                            .where("time",
                            isEqualTo: selectedSlot!)
                            .where("status", whereIn: [
                          "pending",
                          "approved",
                          "shooting",
                          "editing"
                        ])
                            .get();

                        if (existingSlot.docs.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                "This slot is already booked. Please choose another date/time.",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                          return; // ❌ STOP BOOKING
                        }

                        // SLOT IS FREE → CONTINUE BOOKING
                        final userDoc = await FirebaseFirestore.instance
                            .collection("Customer")
                            .doc(uid)
                            .get();

                        String customerName =
                            userDoc["Customer_Name"] ?? "Unknown";

                        // Save Booking
                        await FirebaseFirestore.instance
                            .collection("slot_request")
                            .add({
                          "customer_id": uid,
                          "customer_name": customerName,
                          "date": selectedDateStr,
                          "time": selectedSlot!,
                          "service": "Daily Photo Shoot",
                          "message": "",
                          "status": "pending",
                          "created_at": Timestamp.now(),
                        });

                        // 🔔 Notify Employees
                        final empSnap = await FirebaseFirestore.instance
                            .collection("employee")
                            .get();

                        for (var doc in empSnap.docs) {
                          final token = doc["fcmToken"];
                          if (token != null && token != "") {
                            await PushNotificationService.sendNotification(
                              token: token,
                              title: "New Slot Booking",
                              body:
                              "$customerName booked a slot for ${DateFormat('dd MMM').format(selectedDate)}",
                            );
                          }
                        }

                        // 🔔 Notify Admins
                        final adminSnap = await FirebaseFirestore.instance
                            .collection("admin")
                            .get();

                        for (var doc in adminSnap.docs) {
                          final token = doc["fcmToken"];
                          if (token != null && token != "") {
                            await PushNotificationService.sendNotification(
                              token: token,
                              title: "New Booking Request Sent",
                              body:
                              "$customerName booked a new slot request",
                            );
                          }
                        }

                        // Go to Success Page
                        Navigator.pushNamed(
                          context,
                          '/booking_success',
                          arguments: {
                            'time': selectedSlot!,
                            'date': selectedDate,
                          },
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                    ),
                    child: const Text(
                      'Confirm Booking',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/home');
          if (i == 1) return;
          if (i == 2) Navigator.pushNamed(context, '/subscription');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}
