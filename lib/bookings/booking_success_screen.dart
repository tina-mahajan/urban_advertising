import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Assuming these are in your project structure
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';

// --- Placeholder Classes (Essential for correct coloring) ---
// Please ensure AppColors and CustomBottomNavBar use these or similar definitions in your project files.
class AppColors {
  static const Color backgroundLight = Color(0xFFF0F0F0); // Light background for body
  static const Color backgroundDark = Color(0xFF1E1E1E);  // Dark background for confirmation header
  static const Color primaryBlue = Color(0xFF0C2B4E);     // Accent color (used in text/buttons/bottom nav)
  static const Color successGreen = Color(0xFF4CAF50);    // Bright green for checkmark
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
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
// --- END Placeholder Classes ---


class BookingSuccessScreen extends StatelessWidget {
  final String bookedTime;
  final DateTime bookedDate;

  const BookingSuccessScreen({
    super.key,
    required this.bookedTime,
    required this.bookedDate,
  });

  @override
  Widget build(BuildContext context) {
    // The height of the dark confirmation section
    const double confirmationHeaderHeight = 350;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // We use a custom body wrapper to manage the dark header and the scrollable content
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Dark Confirmation Header Section
            Container(
              height: confirmationHeaderHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0), // Adjust top padding
                  child: Column(
                    children: [
                      // AppBar Content (Back and Close Icons)
                      _buildHeaderActions(context),

                      // Success Content (Icon and Text)
                      const SizedBox(height: 10),
                      _buildSuccessIcon(),
                      const SizedBox(height: 20),
                      const Text(
                        'Thanks! Your booking has\nbeen confirmed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You\'ll receive a reminder 1 hour before\nyour slot.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Light Body Content Section
            Transform.translate(
              // Move the body content up to overlap the dark header edge
              offset: const Offset(0.0, -10.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // 🔹 Selected Slot Summary Card (White, Overlaps Dark Section)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Selected Slot Summary",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                          const Divider(color: Colors.grey, height: 20),
                          _buildSummaryRow(
                              "Date", DateFormat('dd MMM yyyy').format(bookedDate)),
                          _buildSummaryRow("Time", bookedTime),
                          _buildSummaryRow("Duration", "2 Hours"),
                          const SizedBox(height: 10),
                          const Text(
                            "Minimum 4 videos required for each 2-hour slot.",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🔹 View my Schedule Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/bookings'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.5), width: 1.5),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('View my Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                            Icon(Icons.arrow_forward, color: AppColors.primaryBlue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Cancel Booking Button
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/cancel_booking'),
                        child: const Text(
                          'Cancel Booking?',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Fixed Bottom Navbar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
          if (index == 2) Navigator.pushNamed(context, '/plans');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  // Helper Widget for the Top Action Icons
  Widget _buildHeaderActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Summary Rows
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(color: Colors.black54, fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  // Helper Widget for the Success Icon
  Widget _buildSuccessIcon() {
    return Container(
      width: 100, // Slightly reduced size
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 60, // Smaller icon to fit the circle
      ),
    );
  }
}