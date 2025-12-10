import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:urban_advertising/Employee/screens/upload_data_screen.dart';
import 'package:urban_advertising/services/reminder_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:urban_advertising/services/reminder_service.dart';
import 'package:urban_advertising/services/attendance_service.dart';

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

  CarouselItem(
      {required this.title,
        required this.subtitle,
        required this.color,
        required this.icon});
}

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  String employeeName = "";
  String employeeEmail = "";
  bool isLoading = false;

  // -------------- NEW CALENDAR VARIABLES --------------
  Map<DateTime, List<Map<String, dynamic>>> slotEvents = {};
  bool isCalendarLoading = true;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  Future<void> saveEmployeeFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("uid");

    if (uid == null) return;

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection("employee")
          .doc(uid)
          .update({"fcmToken": token});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
    fetchAllSlotDates();
    ReminderService.sendEmployeeTomorrowReminder();
    saveEmployeeFcmToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(notification.title ?? "Notification"),
          content: Text(notification.body ?? ""),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });

  }

  Future<void> fetchEmployeeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");

      if (uid == null) return;

      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection("employee").doc(uid).get();

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

  // -----------------------------------------------------------
  // 🔥 FETCH ALL SLOT DATES FOR CALENDAR HIGHLIGHTING
  // -----------------------------------------------------------
  Future<void> fetchAllSlotDates() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("slot_request").get();

      Map<DateTime, List<Map<String, dynamic>>> temp = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String dateStr = data["date"] ?? "";

        DateTime date = _parseDate(dateStr);

        // skip invalid or unparseable dates
        if (date.year == 1900) continue;

        DateTime normalized = DateTime(date.year, date.month, date.day);

        if (!temp.containsKey(normalized)) {
          temp[normalized] = [];
        }

        temp[normalized]!.add(data);
      }

      setState(() {
        slotEvents = temp;
        isCalendarLoading = false;
      });
    } catch (e) {
      print("Error fetching slot dates: $e");
      setState(() {
        isCalendarLoading = false;
      });
    }
  }

  // ✅ SAFE PARSER – DOESN’T CRASH ON BAD DATA
  DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty || dateStr.trim().isEmpty) {
      print("⚠️ Empty or blank date found.");
      return DateTime(1900); // invalid sentinel
    }

    try {
      List<String> parts = dateStr.trim().split(" ");
      if (parts.length < 3) {
        print("⚠️ Invalid date format: $dateStr");
        return DateTime(1900);
      }

      int day = int.parse(parts[0]);

      const months = {
        "Jan": 1,
        "Feb": 2,
        "Mar": 3,
        "Apr": 4,
        "May": 5,
        "Jun": 6,
        "Jul": 7,
        "Aug": 8,
        "Sep": 9,
        "Oct": 10,
        "Nov": 11,
        "Dec": 12,
        "January": 1,
        "February": 2,
        "March": 3,
        "April": 4,
        "June": 6,
        "July": 7,
        "August": 8,
        "September": 9,
        "October": 10,
        "November": 11,
        "December": 12,
      };

      String monthStr = parts[1];
      if (!months.containsKey(monthStr)) {
        print("⚠️ Unknown month in date: $dateStr");
        return DateTime(1900);
      }

      int month = months[monthStr]!;
      int year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      print("🔥 Date parse failed for: $dateStr  |  error: $e");
      return DateTime(1900);
    }
  }

  // -----------------------------------------------------------

  final int completedProjectsMonth = 18;
  final int targetProjectsMonth = 25;
  final int newRequestsCount = 3;

  String getFormattedToday() {
    final now = DateTime.now();

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

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
        //Notification button
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AttendanceService.markAttendance(
            context: context,
            name: employeeName,
            email: employeeEmail,
            role: "employee",
          );
        },

        label: const Text('Mark Attendance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.fingerprint_rounded),
        backgroundColor: AppColors.primaryAccentLight,
        foregroundColor: AppColors.textLight,
      ),

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

      body: isLoading
          ? Center(
          child:
          CircularProgressIndicator(color: AppColors.primaryAccentLight))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            _buildCarousel(),
            const SizedBox(height: 25),

            _buildSectionHeader('Monthly Performance'),
            const SizedBox(height: 15),
            _buildStatsGrid(),
            const SizedBox(height: 30),

            if (newRequestsCount > 0) _buildNewRequestsCard(),
            const SizedBox(height: 30),

            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 15),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 30),

            // ---------------------- UPDATED SECTION ----------------------
            _buildSectionHeader("Booking Calendar"),
            const SizedBox(height: 15),
            _buildCalendar(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------------- CALENDAR WIDGET ----------------------

  Widget _buildCalendar() {
    if (isCalendarLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAccent),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: CalendarFormat.month,

        selectedDayPredicate: (day) =>
        selectedDay != null &&
            day.year == selectedDay!.year &&
            day.month == selectedDay!.month &&
            day.day == selectedDay!.day,

        onDaySelected: (selected, focused) {
          setState(() {
            selectedDay = selected;
            focusedDay = focused;
          });

          DateTime key =
          DateTime(selected.year, selected.month, selected.day);
          List events = slotEvents[key] ?? [];

          if (events.isNotEmpty) {
            _showEventsBottomSheet(events);
          }
        },

        eventLoader: (day) {
          DateTime d = DateTime(day.year, day.month, day.day);
          return slotEvents[d] ?? [];
        },

        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white70),
          weekendStyle: TextStyle(color: Colors.white70),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white70),

          todayDecoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            shape: BoxShape.circle,
          ),

          selectedDecoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.circle,
          ),

          markerDecoration: BoxDecoration(
            color: AppColors.primaryAccentLight,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _showEventsBottomSheet(List events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Booked Slots",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              for (var e in events)
                ListTile(
                  title: Text(e["customer_name"],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${e["time"]} • ${e["service"]}",
                      style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white),
                )
            ],
          ),
        );
      },
    );
  }

  // ---------------- REST OF YOUR ORIGINAL WIDGETS (UNCHANGED) ----------------
  Widget _buildCarousel() => SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: carouselItems.length,
      itemBuilder: (context, index) {
        final item = carouselItems[index];
        return Container(
          width: 250,
          margin: const EdgeInsets.only(right: 15),
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
                      style: TextStyle(
                          color: item.color,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.subtitle,
                  style: const TextStyle(
                      color: AppColors.textLight, fontSize: 16)),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Projects Done',
                    '$completedProjectsMonth', Icons.check_circle_outline,
                    AppColors.primaryAccent)),
            const SizedBox(width: 15),
            Expanded(
                child: _buildStatCard('Monthly Target',
                    '$targetProjectsMonth', Icons.track_changes_outlined,
                    AppColors.secondaryAccent)),
          ],
        ),
        const SizedBox(height: 15),
        _buildProgressCard(),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 24)),
          Text(label,
              style: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.7),
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    double progress = completedProjectsMonth / targetProjectsMonth;
    if (progress > 1.0) progress = 1.0;
    int percentage = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E40C2),
            Color(0xFF8A63D2),
            Color(0xFF5CC8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Progress',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Icon(Icons.trending_up, color: Colors.white, size: 30),
            ],
          ),
          const SizedBox(height: 12),
          Text('$percentage%',
              style: const TextStyle(color: Colors.white, fontSize: 48)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

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
          const Icon(Icons.assignment_late,
              color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$newRequestsCount New Project Requests',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'label': 'Upload Data',
        'icon': Icons.cloud_upload,
        'color': AppColors.primaryAccent
      },
      {
        'label': 'Project Queue',
        'icon': Icons.assignment_turned_in,
        'color': AppColors.secondaryAccent
      },
      {
        'label': 'Report Prob',
        'icon': Icons.bug_report,
        'color': AppColors.errors
      },
      {
        'label': 'Resources',
        'icon': Icons.folder_open,
        'color': Colors.amber
      },
      {
        'label': 'Help & FAQ',
        'icon': Icons.help_outline,
        'color': Colors.cyan
      },
      {
        'label': 'Team Chat',
        'icon': Icons.chat_bubble_outline,
        'color': Colors.pinkAccent
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final a = actions[index];

        return GestureDetector(
          onTap: () {
            if (a['label'] == 'Upload Data') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadDataScreen(),
                ),
              );
            }

            // Add more navigation below if needed
            // else if (a['label'] == 'Project Queue') {}
          },
          child: _buildActionButton(
            a['icon'] as IconData,
            a['label'] as String,
            a['color'] as Color,
          ),
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
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}//Original COde