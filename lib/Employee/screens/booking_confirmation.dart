import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFF5A00FF);
  static const Color secondaryAccent = Color(0xFF00FFFF);
  static const Color secondaryText = Colors.white70;
  static const Color textLight = Colors.white;
  static const Color completedColor = Color(0xFF388E3C);
  static const Color pendingColor = Color(0xFFFFC107);
}

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const clientName = 'Rahul Sharma';
    const location = 'Crown Taloja';
    const time = '10:00 AM - 12:00 PM';
    const projectType = 'Social Media Marketing Shoot';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryAccent),
        title: const Text(
          "Booking Request",
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.secondaryAccent.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "New Booking Request",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text("Client: $clientName",
                  style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              Text("Project Type: $projectType",
                  style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: AppColors.secondaryAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(time,
                      style: const TextStyle(color: AppColors.secondaryText)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.secondaryAccent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(location,
                        style: const TextStyle(color: AppColors.secondaryText)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Divider(color: AppColors.secondaryAccent, thickness: 0.4),
              const SizedBox(height: 20),
              const Text(
                "Please confirm this booking request.",
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Booking Confirmed!"),
                            backgroundColor: AppColors.completedColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.completedColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: const Text(
                        "CONFIRM",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Booking Rejected"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        "REJECT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
