import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  String formatDateNum(DateTime d) => DateFormat('dd').format(d);
  String formatDateMonth(DateTime d) => DateFormat('MMM').format(d);

  // ==============================
  // BOOKING API CALL
  // ==============================
  Future<void> createBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please login again.")));
      return;
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2:4000/api/bookings/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "date": selectedDate.toIso8601String().split("T")[0],
        "time_slot": selectedSlot,
      }),
    );

    print("BOOKING RESPONSE = ${response.body}");

    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '/booking_success');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: ${response.body}")),
      );
    }
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Book a Slot",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      // ==============================
      // BODY
      // ==============================
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CURRENT PLAN CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Plan: Standard plan (15 Videos)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  SizedBox(height: 5),
                  Text("You’ve posted 12 videos so far",
                      style: TextStyle(color: AppColors.textDark)),
                ],
              ),
            ),
          ),

          // Available Slots
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Available Slots",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
          ),

          const SizedBox(height: 16),

          // DATE SELECTOR
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final bool isSelected =
                    date.day == selectedDate.day &&
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
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.accent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(formatDateNum(date),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark)),
                        Text(formatDateMonth(date),
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // SLOT CARDS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                itemCount: slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final isSelected = slot == selectedSlot;

                  return GestureDetector(
                    onTap: () => setState(() => selectedSlot = slot),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.accent,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          slot,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.access_time,
                          color:
                          isSelected ? AppColors.primary : AppColors.accent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // SUMMARY BOX
          if (selectedSlot != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selected Slot Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text("Date: ${DateFormat('dd MMM').format(selectedDate)}",
                        style: const TextStyle(color: AppColors.textDark)),
                    Text("Time: $selectedSlot",
                        style: const TextStyle(color: AppColors.textDark)),
                    const Text("Duration: 2 Hours",
                        style: TextStyle(color: AppColors.textDark)),
                    const SizedBox(height: 3),
                    const Text(
                      "Minimum 4 videos required for each 2-hour slot.",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // CONFIRM BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedSlot == null
                    ? null
                    : () {
                  createBooking();
                },
                child: const Text("Confirm Booking"),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),

      // BOTTOM NAV BAR
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
