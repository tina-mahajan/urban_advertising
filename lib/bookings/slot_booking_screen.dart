import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for DateFormat
// Retaining original imports, assume these paths are correct in your project
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';

// --- Placeholder Classes (Updated for Dark Theme) ---
// Remove these if you already have them defined in their respective files.
class AppColors {
  static const Color darkBackground = Color(0xFF141414); // Primary dark background
  static const Color cardBackground = Color(0xFF1E1E1E); // Dark card color
  static const Color primaryAccent = Color(0xFF0C2B4E); // Primary accent (purple/blue from screenshots)
  static const Color nav = Color(0xFF00BFFF); // Primary accent (purple/blue from screenshots)
  static const Color secondaryText = Colors.white70;
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.featured_play_list), label: 'Plans'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedItemColor: AppColors.nav, // Use accent color
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black, // Dark background for navbar
    );
  }
}
// End of placeholders

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  String? selectedSlot;
  DateTime selectedDate = DateTime.now(); // State for the selected date

  final List<String> slots = [
    '10:00AM - 12:00PM',
    '01:00PM - 03:00PM',
    '04:00PM - 06:00PM',
    '07:00PM - 09:00PM',
  ];

  // List of dates for the horizontal selector
  List<DateTime> get dates {
    List<DateTime> list = [];
    for (int i = 0; i < 7; i++) {
      list.add(DateTime.now().add(Duration(days: i)));
    }
    return list;
  }

  // Helper to format date using the imported DateFormat
  String formatDateDay(DateTime date) => DateFormat('EE').format(date);
  String formatDateNum(DateTime date) => DateFormat('dd').format(date);
  String formatDateMonth(DateTime date) => DateFormat('MMM').format(date);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // 1. Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.black, // 2. Dark Appbar background (no gradient needed)
          ),
        ),
        title: const Text(
          'Book a Slot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              backgroundColor: AppColors.primaryAccent, // Accent background
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      // 🔹 Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Dark Current Plan Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground, // Dark card background
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Available Slots',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
            ),
          ),
          const SizedBox(height: 16),

          // 📅 Horizontal Date Selector
          SizedBox(
            height: 80, // Height for the date selector
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final bool isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedSlot = null; // Reset slot selection on date change
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryAccent : AppColors.cardBackground, // Dark background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryAccent : Colors.grey.shade700,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isSelected ? 0.5 : 0.2), // Dark shadow
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatDateNum(date),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateMonth(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppColors.secondaryText,
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

          // 🔹 Slots List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                itemCount: slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final bool isSelected = slot == selectedSlot;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSlot = slot),
                    child: Card(
                      // FIX: Replaced .withAlpha(20) for a subtle dark glow
                      color: isSelected ? AppColors.primaryAccent.withAlpha(20) : AppColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryAccent : Colors.grey.shade700,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          slot,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelected ? Icons.check_circle : Icons.schedule,
                          color: isSelected ? AppColors.primaryAccent : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 🔹 Slot Summary Box (visible after selection)
          if (selectedSlot != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground, // Dark background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selected Slot Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 8),
                    // Use DateFormat to display the selected date
                    Text("Date: ${DateFormat('dd MMM').format(selectedDate)}",
                        style: const TextStyle(color: AppColors.secondaryText)),
                    Text("Time: $selectedSlot",
                        style: const TextStyle(color: AppColors.secondaryText)),
                    const Text("Duration: 2 Hours",
                        style: TextStyle(color: AppColors.secondaryText)),
                    const SizedBox(height: 4),
                    const Text(
                      "Minimum 4 videos required for each 2-hour slot.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedSlot == null
                    ? null
                    : () {
                  // FIX: Ensure both date and time are passed for the confirmation screen
                  Navigator.pushNamed(context, '/booking_success',
                      arguments: {
                        'time': selectedSlot!,
                        'date': selectedDate,
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent, // Accent color for button
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  // FIX: Use .withAlpha() to replace deprecated .withOpacity()
                  disabledBackgroundColor: AppColors.primaryAccent.withAlpha(127),
                ),
                child: const Text('Confirm Booking',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 16), // Space before bottom navbar
        ],
      ),

      // 🔹 Fixed Bottom Navbar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // <-- 1 because this is the "Slot Booking" tab
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/home');
          if (i == 1) return; // Already on Booking page
          if (i == 2) Navigator.pushNamed(context, '/subscription');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}