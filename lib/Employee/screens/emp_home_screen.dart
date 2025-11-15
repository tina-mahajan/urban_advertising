import 'package:flutter/material.dart';

// --- Placeholder/Themed Colors ---
class AppColors {
  static const Color darkBackground = Color(0xFF141414);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryAccent = Color(0xFF5A00FF);     // Primary Purple/Blue accent
  static const Color secondaryAccent = Color(0xFF00FFFF);  // Cyan for secondary actions
  static const Color secondaryText = Colors.white70;
  static const Color textLight = Colors.white;
}
// ---------------------------------

// Dummy Data Models (Updated with Growth/Request data)
class EmployeeBooking {
  final String time;
  final String clientName;
  final String location;
  final String projectType;
  final bool isCompleted;

  EmployeeBooking({
    required this.time,
    required this.clientName,
    required this.location,
    required this.projectType,
    this.isCompleted = false,
  });
}

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  // Sample data for Today's schedule
  final List<EmployeeBooking> todaySchedule = [
    EmployeeBooking(
        time: '10:00 AM - 12:00 PM',
        clientName: 'Sangam Collection',
        location: 'Bhosari',
        projectType: 'Daily Shoot'),
    // ... other bookings
  ];

  // Dummy data for Growth and Requests
  final int completedProjectsMonth = 18;
  final int targetProjectsMonth = 25;
  final int newRequestsCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Employee Dashboard',
          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textLight),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Welcome & Stats Card ---
            _buildWelcomeCard(),
            const SizedBox(height: 20),

            // --- 2. Growth Overview Card (NEW) ---
            _buildGrowthOverviewCard(),
            const SizedBox(height: 20),

            // --- 3. New Requests Card (NEW) ---
            if (newRequestsCount > 0)
              _buildNewRequestsCard(),
            const SizedBox(height: 20),

            // --- 4. Quick Actions ---
            _buildSectionHeader('Quick Actions'),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 25),

            // --- 5. Today's Schedule ---
            _buildSectionHeader("Today's Schedule (${_getTodayDate()})"),
            _buildScheduleList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- NEW Widget Builders ---

  Widget _buildGrowthOverviewCard() {
    double progress = completedProjectsMonth / targetProjectsMonth;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Growth Goal',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.secondaryAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.secondaryText.withOpacity(0.2),
            color: AppColors.secondaryAccent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed: $completedProjectsMonth',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              Text(
                'Target: $targetProjectsMonth',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestsCard() {
    return InkWell(
      onTap: () {
        // Navigate to the unassigned requests screen
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.2), // Use primary accent for alert
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primaryAccent, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_late, color: AppColors.primaryAccent, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$newRequestsCount New Project Requests',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to review and assign tasks immediately.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textLight, size: 18),
          ],
        ),
      ),
    );
  }

  // --- Existing Widget Builders (Kept for completeness) ---

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1]} ${now.year}';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Trupti!',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Active Projects: 4 pending submissions',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Status:',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
              Chip(
                backgroundColor: Color(0xFF333333),
                side: BorderSide(color: Colors.green, width: 1),
                label: Text(
                  'On Shift',
                  style: TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildActionButton(
          icon: Icons.upload_file,
          label: 'Upload Data',
          color: AppColors.primaryAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening file upload tool...')),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.assignment,
          label: 'Project Queue',
          color: AppColors.secondaryAccent,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.bug_report,
          label: 'Report Problem',
          color: Colors.redAccent,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.folder_open,
          label: 'Resources',
          color: Colors.orangeAccent,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todaySchedule.length,
      itemBuilder: (context, index) {
        final booking = todaySchedule[index];
        final isCompleted = booking.isCompleted;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? Colors.greenAccent.withOpacity(0.4)
                  : AppColors.primaryAccent.withOpacity(0.4),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? Colors.greenAccent.withOpacity(0.12)
                    : AppColors.primaryAccent.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Time + Status Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: AppColors.secondaryAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        booking.time,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    backgroundColor: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.yellow.withOpacity(0.15),
                    side: BorderSide(
                      color: isCompleted ? Colors.green : Colors.yellowAccent,
                      width: 0.8,
                    ),
                    label: Text(
                      isCompleted ? 'Completed' : 'Pending',
                      style: TextStyle(
                        color:
                        isCompleted ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Client Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.secondaryText, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.clientName,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Location Info
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.location,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Project Type Info
              Row(
                children: [
                  const Icon(Icons.work_outline,
                      color: AppColors.primaryAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.projectType,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons
              if (!isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request confirmed.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent, size: 18),
                      label: const Text(
                        'Mark Done',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule option coming soon.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.schedule,
                          color: Colors.yellowAccent, size: 18),
                      label: const Text(
                        'Reschedule',
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

}