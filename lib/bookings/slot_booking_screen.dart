//slot booking

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      extendBodyBehindAppBar: false,   // FIXED
      appBar: AppBar(
        backgroundColor: Colors.black, // FIXED
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
                Navigator.pushNamed(context, '/profile');   // <-- Navigate to Profile
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

      // SAFE AREA FIXES THE EXTRA TOP SPACE
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Current Plan Box — Fixed Spacing
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
                      style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

            // Title
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
                  final isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;

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
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : Colors.grey.shade700,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd').format(date),
                            style: TextStyle(
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

            // 🔹 SLOT LIST + EXPANDABLE SUMMARY
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
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
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slot Header
                            GestureDetector(
                              onTap: () =>
                                  setState(() => selectedSlot = slot),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
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
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      "Time:  $slot",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const Text(
                                      "Duration:  2 Hours",
                                      style: TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Minimum 4 videos required for each 2-hour slot.",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12),
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
              ),
            ),

            // Confirm Button
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedSlot == null ? null : () async {
                    try {
                      // Get user ID
                      final prefs = await SharedPreferences.getInstance();
                      String? uid = prefs.getString("uid");

                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login required")),
                        );
                        return;
                      }

                      // Fetch customer details
                      final userDoc = await FirebaseFirestore.instance
                          .collection("Customer")
                          .doc(uid)
                          .get();

                      String customerName = userDoc["Customer_Name"] ?? "Unknown";

                      // Save to Firestore
                      await FirebaseFirestore.instance.collection("slot_request").add({
                        "customer_id": uid,
                        "customer_name": customerName,
                        "date": DateFormat("dd MMM yyyy").format(selectedDate),
                        "time": selectedSlot!,
                        "service": "Daily Photo Shoot",   // or dynamic
                        "message": "",
                        "status": "pending",
                        "created_at": Timestamp.now(),
                      });

                      // Navigate to success page
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
                        SnackBar(content: Text("Error booking slot: $e")),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    disabledBackgroundColor:
                    AppColors.primaryAccent.withAlpha(120),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style:
                    TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
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
