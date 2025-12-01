import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF1E1E1E);

  static const Color primaryBlue = Color(0xFF0C2B4E);
  static const Color pendingYellow = Color(0xFFF7C948);
  static const Color pendingBg = Color(0xFFFFF4CC);

  static const Color cardWhite = Colors.white;
  static const Color textDark = Colors.black87;
}

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ------------------ HEADER (Pending) ------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PENDING ICON
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.pendingBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pendingYellow.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.pendingYellow,
                      size: 65,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Slot Request Submitted",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Our team will review your request.\nYou'll get an update soon!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ------------------ SLOT DETAILS CARD ------------------
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Slot Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),

                  const Divider(height: 30),

                  _infoRow("Date", DateFormat('dd MMM yyyy').format(bookedDate)),
                  _infoRow("Time", bookedTime),
                  _infoRow("Duration", "2 Hours"),

                  const SizedBox(height: 12),

                  const Text(
                    "You will receive a confirmation once the employee approves your slot.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ------------------ SEE BOOKINGS ------------------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/bookings"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "View My Booking Requests",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Home",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black54, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
