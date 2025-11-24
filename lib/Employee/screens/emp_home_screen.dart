import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';

import 'dart:math' as math;

// Import the new theme file
import 'package:urban_advertising/core/theme.dart';


class AppColors {
  // Main Theme Colors
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color cardBackground = Color(0xFF161B22);
  static const Color primaryAccent = Color(0xFF6E40C2);
  static const Color primaryAccentLight = Color(0xFF8A63D2);
  static const Color secondaryAccent = Color(0xFF5CC8FF);

  // Text
  static const Color textLight = Colors.white;
  static const Color secondaryText = Color(0xFFC9D1D9);

  // Status
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFFAC85E);
  static const Color error = Color(0xFFFACA62);
  static const Color errors = Color(0xFFFF0000);

  // UI Elements
  static const Color divider = Color(0xFF30363D);
  static const Color glow = Color(0xFF8A63D2);
}

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

class CarouselItem {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  CarouselItem({required this.title, required this.subtitle, required this.color, required this.icon});
}

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  String employeeName = "";
  String employeeEmail = "";
  bool isLoading = false;

  Future<void> fetchEmployeeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");

      if (uid == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("employee")
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          employeeName = doc["name"] ?? "";
          employeeEmail = doc["email"] ?? "";
        });
      }

    } catch (e) {
      print("Error fetching employee data: $e");
    }
  }

  final int completedProjectsMonth = 18;
  final int targetProjectsMonth = 25;
  final int newRequestsCount = 3;

  final List<EmployeeBooking> todaySchedule = [
    EmployeeBooking(
      time: '10:00 AM',
      clientName: 'Sangam Collection',
      location: 'Bhosari, Pune',
      projectType: 'Daily Photo Shoot',
    ),
    EmployeeBooking(
      time: '04:00 PM',
      clientName: 'Client Review Meeting',
      location: 'Office Meeting Room',
      projectType: 'Project Planning',
    ),
  ];

  final List<CarouselItem> carouselItems = [
    CarouselItem(
      title: "Weekly Focus",
      subtitle: "Finish 5 Video Edits",
      color: Colors.blueAccent,
      icon: Icons.lightbulb_outline,
    ),
    CarouselItem(
      title: "Hit Your Target!",
      subtitle: "7 more projects",
      color: AppColors.primaryAccent,
      icon: Icons.rocket_launch,
    ),
    CarouselItem(
      title: "Creative Corner",
      subtitle: "Review guidelines",
      color: AppColors.success,
      icon: Icons.design_services,
    ),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Hello!, ${employeeName.isNotEmpty ? employeeName.split(" ").first : ""}',
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.secondaryText, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryAccent,
              child: Text(
                employeeName.isNotEmpty ? employeeName[0] : "?",
                style: const TextStyle(
                    color: AppColors.textLight, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      // ---------------- FAB ----------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Mark Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.fingerprint_rounded),
        backgroundColor: AppColors.primaryAccentLight,
        foregroundColor: AppColors.textLight,
      ),

      // ✅ ADD NAVBAR HERE INSIDE SCAFFOLD
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, "/emp_slots");
              break;
            case 2:
              Navigator.pushNamed(context, "/clients");
              break;
            case 3:
              Navigator.pushNamed(context, "/employee_profile");
              break;
          }
        },
      ),
      // ---------------- BODY ----------------
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryAccentLight))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // CAROUSEL
            _buildCarousel(),
            const SizedBox(height: 25),

            // MONTHLY PERFORMANCE
            _buildSectionHeader('Monthly Performance'),
            const SizedBox(height: 15),
            _buildStatsGrid(),
            const SizedBox(height: 30),

            // NEW REQUESTS
            if (newRequestsCount > 0) _buildNewRequestsCard(),
            const SizedBox(height: 30),

            // QUICK ACTIONS
            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 30),

            // TODAY'S SCHEDULE
            _buildSectionHeader("Today's Schedule (${_getTodayDate()})"),
            const SizedBox(height: 15),
            _buildScheduleList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }


  // ---------------- CAROUSEL ----------------
  Widget _buildCarousel() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: carouselItems.length,
        itemBuilder: (context, index) {
          final item = carouselItems[index];
          return Container(
            width: 250,
            margin: EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: item.color.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(item.icon, color: item.color, size: 22),
                    const SizedBox(width: 8),
                    Text(item.title,
                        style: TextStyle(color: item.color, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.subtitle,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- SECTION HEADER ----------------
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ---------------- STATS GRID ----------------
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Projects Done', '$completedProjectsMonth',
                Icons.check_circle_outline, AppColors.primaryAccent)),
            const SizedBox(width: 15),
            Expanded(child: _buildStatCard('Monthly Target', '$targetProjectsMonth',
                Icons.track_changes_outlined, AppColors.secondaryAccent)),
          ],
        ),
        const SizedBox(height: 15),
        _buildProgressCard(),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: AppColors.secondaryText.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  // ---------------- PROGRESS CARD ----------------
  Widget _buildProgressCard() {
    double progress = completedProjectsMonth / targetProjectsMonth;
    if (progress > 1.0) progress = 1.0;
    int percentage = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        // 🔥 Futuristic Neon Gradient
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E40C2),        // Deep Purple
            Color(0xFF8A63D2),        // Light Purple
            Color(0xFF5CC8FF),        // Cyan Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        // Glow shadow
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.trending_up, color: Colors.white, size: 30),
            ],
          ),

          const SizedBox(height: 12),

          // Main Number
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ---------------- NEW REQUESTS CARD ----------------
  Widget _buildNewRequestsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_late, color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$newRequestsCount New Project Requests',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'label': 'Upload Data', 'icon': Icons.cloud_upload, 'color': AppColors.primaryAccent},
      {'label': 'Project Queue', 'icon': Icons.assignment_turned_in, 'color': AppColors.secondaryAccent},
      {'label': 'Report Prob', 'icon': Icons.bug_report, 'color': AppColors.error},
      {'label': 'Resources', 'icon': Icons.folder_open, 'color': Colors.amber},
      {'label': 'Help & FAQ', 'icon': Icons.help_outline, 'color': Colors.cyan},
      {'label': 'Team Chat', 'icon': Icons.chat_bubble_outline, 'color': Colors.pinkAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemBuilder: (context, index) {
        final a = actions[index];
        return _buildActionButton(
          a['icon'] as IconData,
          a['label'] as String,
          a['color'] as Color,
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // ---------------- SCHEDULE LIST ----------------
  Widget _buildScheduleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todaySchedule.length,
      itemBuilder: (context, index) {
        final booking = todaySchedule[index];
        final isCompleted = booking.isCompleted;

        final borderColor = isCompleted ? AppColors.success : AppColors.secondaryAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success.withOpacity(0.07) : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Marker
              Column(
                children: [
                  Text(booking.time,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Container(
                    width: 3,
                    height: 40,
                    margin: const EdgeInsets.only(top: 5),
                    color: borderColor,
                  ),
                ],
              ),
              const SizedBox(width: 15),

              // Main Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.clientName,
                        style: TextStyle(
                          color: isCompleted ? AppColors.success : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work_outline, color: AppColors.primaryAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.projectType,
                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.location,
                            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status
              Chip(
                backgroundColor: isCompleted ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
                label: Text(
                  isCompleted ? 'Done' : 'Pending',
                  style: TextStyle(
                      color: isCompleted ? AppColors.success : AppColors.errors,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- DATE ----------------
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day} ${[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][now.month - 1]} ${now.year}';
  }
}
