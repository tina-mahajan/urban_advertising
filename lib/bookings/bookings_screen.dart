import 'package:flutter/material.dart';
// Assuming the path is correct
import '../../core/theme.dart';
// Assuming this import is correctly defined
import 'booking_history_screen.dart';

// --- Placeholder Colors (MUST match your actual AppColors definition) ---
class AppColors {
  static const Color darkBackground = Color(0xFF141414);  // Primary dark background
  static const Color cardBackground = Color(0xFF1E1E1E);   // Dark card/surface color
  static const Color primaryAccent = Color(0xFF5A00FF);   // Your main accent color (Purple/Blue)
  static const Color secondaryText = Colors.white70;       // Light grey text
}
// --- END Placeholder Colors ---


class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // 1. Dark Background
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white), // White title
        ),
        backgroundColor: Colors.black, // Dark AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Book a New Slot Card
                  Card(
                    color: AppColors.cardBackground, // Dark card color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: AppColors.primaryAccent), // Accent Icon
                      title: const Text(
                        'Book a New Slot',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Choose your preferred time slot',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryText),
                      onTap: () {
                        Navigator.pushNamed(context, '/slot_booking');
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Booking History Card
                  Card(
                    color: AppColors.cardBackground, // Dark card color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: AppColors.primaryAccent), // Accent Icon
                      title: const Text(
                        'Booking History',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'View your past bookings',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryText),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const BookingHistoryScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Back to Home Button (Accent Color)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent, // Accent button
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}