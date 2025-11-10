import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for DateFormat
// Retaining original imports, assume these paths are correct in your project
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';

// Placeholder classes (Kept for completeness and to resolve dependencies)
class AppColors {
  // Using your new color (0xFF0C2B4E)
  static const Color background = Color(0xFFF0F0F0);
  static const Color primaryBlue = Color(0xFF0C2B4E);
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ⚠️ CRITICAL FIX: The structure must only return the BottomNavigationBar,
    // and its 'items' list must contain only BottomNavigationBarItem widgets.
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        // These are the only valid children for the 'items' list
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.featured_play_list), label: 'Plans'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C2B4E), Color(0xFF0C2B4E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
              // Replace with your actual asset image path
              // backgroundImage: AssetImage('assets/profile.png'),
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF0C2B4E)),
            ),
          ),
        ],
      ),

      // 🔹 Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Gradient Current Plan Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C2B4E), Color(0xFF0C2B4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
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
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Available Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(isSelected ? 0.3 : 0.1),
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
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateMonth(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black54,
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
                      color: isSelected
                          ? AppColors.primaryBlue.withAlpha(20)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          slot,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.schedule,
                          color:
                          isSelected ? AppColors.primaryBlue : Colors.grey,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selected Slot Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    // Use DateFormat to display the selected date
                    Text("Date: ${DateFormat('dd MMM').format(selectedDate)}",
                        style: const TextStyle(color: Colors.black87)),
                    Text("Time: $selectedSlot",
                        style: const TextStyle(color: Colors.black87)),
                    const Text("Duration: 2 Hours",
                        style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text(
                      "Minimum 4 videos required for each 2-hour slot.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
                  Navigator.pushNamed(context, '/booking_success',
                      arguments: selectedSlot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.primaryBlue.withAlpha(127),
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
      // FIX: The CustomBottomNavBar widget is called here correctly,
      // and the navigation logic is placed inside the onTap callback.
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