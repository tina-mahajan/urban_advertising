import 'package:flutter/material.dart';
// Assuming the path is correct
import '../../core/theme.dart';

// --- Placeholder Colors (MUST match your actual AppColors definition) ---
// If these are defined elsewhere, ensure your core/theme.dart matches:
class AppColors {
  static const Color darkBackground = Color(0xFF141414); // Primary dark background
  static const Color cardBackground = Color(0xFF1E1E1E);  // Dark card/surface color
  static const Color primaryAccent = Color(0xFF5A00FF);  // Your main accent color (Purple/Blue)
  static const Color secondaryText = Colors.white70;      // Light grey text
}
// --- END Placeholder Colors ---


class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // 1. Dark Background
      appBar: AppBar(
        title: const Text(
          'Cancel Booking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // Dark AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please provide a reason (optional):',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16), // Light grey text
            ),
            const SizedBox(height: 10),
            // 4. Dark Mode TextField Styling
            TextField(
              controller: _reasonController,
              cursorColor: AppColors.primaryAccent,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                fillColor: AppColors.cardBackground, // Dark card background for input field
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Hide default border for a cleaner look
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryAccent, width: 2), // Accent border on focus
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            // 5. Accent Colored Button
            ElevatedButton(
              onPressed: () {
                // Simulate cancellation confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    // Dark theme alert dialog (optional: adjust colors if you have a custom AlertDialog theme)
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Booking Cancelled', style: TextStyle(color: Colors.white)),
                    content: const Text(
                        'Your booking has been successfully cancelled.', style: TextStyle(color: AppColors.secondaryText)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Navigate back to the main bookings screen or home
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/bookings', (route) => false);
                        },
                        child: Text('OK', style: TextStyle(color: AppColors.primaryAccent)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent, // Accent button color
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                  'Confirm Cancellation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 15),
            // Text Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Go Back',
                  // Use white or light grey for consistency, or keep accent color if desired
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}