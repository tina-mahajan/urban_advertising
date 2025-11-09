import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// Assuming these are in your project structure or use the placeholders
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/widgets/bottom_navbar.dart';

// --- Placeholder Classes (REMOVE if you have these defined globally) ---
// If you have your AppColors and CustomBottomNavBar already,
// you do NOT need these placeholder definitions.

class AppColors {
  static const Color background = Color(0xFFF0F0F0); // Light grey background
  static const Color primaryBlue = Color(0xFF0C2B4E); // Your primary blue
  static const Color successGreen = Color(0xFF4CAF50); // A bright green for success
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
  // This screen will likely receive the booked slot details as arguments.
  // For demonstration, let's assume it receives the 'time' as a String
  // and 'date' as a DateTime.
  final String bookedTime;
  final DateTime bookedDate;

  const BookingSuccessScreen({
    super.key,
    required this.bookedTime,
    required this.bookedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Visible against dark header
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Navigate back to home or a main screen
              Navigator.of(context).popUntil((route) => route.isFirst); // Example: Pop all routes until the first
            },
          ),
        ],
        // The header area where the success message appears
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E), // Dark background for the top section
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💡 Success Icon and Confetti effect (simplified)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Confetti Effect Placeholder (You'd use a package like 'confetti' for real effect)
                    // For now, just a gradient circle to suggest the effect
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.successGreen.withAlpha(50), // Lighter green for glow
                            AppColors.successGreen.withAlpha(0),   // Transparent
                          ],
                          radius: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successGreen.withAlpha(100),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thanks! Your booking has\nbeen confirmed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ll receive a reminder 1 hour before\nyour slot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20), // Extra space
              ],
            ),
          ),
        ),
        toolbarHeight: 280, // Adjust height to fit content
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Selected Slot Summary
            Container(
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
                  Text(
                    "Date: ${DateFormat('dd MMM').format(bookedDate)}", // Using the passed date
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    "Time: $bookedTime", // Using the passed time
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const Text("Duration: 2 Hours", // Assuming 2 hours as per previous screen
                      style: TextStyle(color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text(
                    "Minimum 4 videos required for each 2-hour slot.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 View my Schedule Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation to "My Schedule" page
                  print("View my Schedule tapped!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('View my Schedule',
                        style: TextStyle(fontSize: 16, color: AppColors.primaryBlue)),
                    Icon(Icons.arrow_forward, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Cancel Booking Button
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement logic to cancel booking
                  print("Cancel Booking tapped!");
                },
                child: const Text(
                  'Cancel Booking?',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Fixed Bottom Navbar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Still on a 'Booking' related flow
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
              // Or Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
            // Currently on booking confirmation, maybe pop back to slot selection or home
              Navigator.of(context).popUntil((route) => route.isFirst); // Example: Go to home
              break;
            case 2:
              Navigator.pushNamed(context, '/plans');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}