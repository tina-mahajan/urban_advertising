import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/screens/auth/login_screen.dart';
import 'admin_add_order_screen.dart';
import 'package:urban_advertising/services/reminder_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/services/push_notification_service.dart';
import 'package:urban_advertising/Admin/screens/admin_booking_details_screen.dart';
import 'package:urban_advertising/Admin/admin_customers_screen.dart';
import 'package:urban_advertising/Admin/admin_employees_screen.dart';
import 'package:urban_advertising/Admin/admin_settings_screen.dart';
import 'package:urban_advertising/Admin/admin_revenue_screen.dart';
import 'package:urban_advertising/Admin/admin_attendance_screen.dart';
import 'package:urban_advertising/Admin/admin_services_screen.dart';
import 'package:urban_advertising/services/attendance_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isCalendarLoading = true;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now();

  Map<DateTime, List<Map<String, dynamic>>> slotEvents = {};
  late StreamSubscription<QuerySnapshot> _calendarSub;

  String _selectedFilter = 'upcoming';
  int _currentIndex = 0;

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  Future<void> saveAdminFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("uid");

    if (uid == null) return;

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection("admin")
          .doc(uid)
          .update({"fcmToken": token});
    }
  }

  Stream<QuerySnapshot> _allBookingsStream() {
    return FirebaseFirestore.instance
        .collection('slot_request')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Stream<int> _countByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('slot_request')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  void initState() {
    super.initState();
    ReminderService.sendAdminTomorrowReminder();
    focusedDay = DateTime.now();
    selectedDay = DateTime.now();
    saveAdminFcmToken();

    _calendarSub = FirebaseFirestore.instance
        .collection('slot_request')
        .snapshots()
        .listen(_updateEventsFromSnapshot);

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

  @override
  void dispose() {
    _calendarSub.cancel();
    super.dispose();
  }

  void _updateEventsFromSnapshot(QuerySnapshot snapshot) {
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dateStr = (data['date'] ?? '').toString().trim();
      if (dateStr.isEmpty) continue;

      try {
        final dt = _dateFormatter.parse(dateStr);
        final key = DateTime(dt.year, dt.month, dt.day);
        final event = {...data, 'id': doc.id};

        events.putIfAbsent(key, () => []).add(event);
      } catch (_) {}
    }

    setState(() {
      slotEvents = events;
      isCalendarLoading = false;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return slotEvents[d] ?? [];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
        return Colors.orangeAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'done':
        return AppColors1.primaryAccent;
      default:
        return Colors.white;
    }
  }

  List<QueryDocumentSnapshot> _filterWeeklyDocs(
      List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 25));

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final dateStr = (data['date'] ?? '').toString().trim();
      if (dateStr.isEmpty) return false;

      DateTime bookingDate;
      try {
        bookingDate = _dateFormatter.parse(dateStr);
      } catch (_) {
        return false;
      }

      final dateOnly =
      DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      if (dateOnly.isBefore(today) || dateOnly.isAfter(weekEnd)) return false;

      final status = (data['status'] ?? '').toString().toLowerCase();

      if (_selectedFilter == 'pending') return status == 'pending';
      if (_selectedFilter == 'done') return status == 'done';

      // upcoming
      return status == 'pending' || status == 'approved';
    }).toList();
  }

  // ================== UI BUILD ==================

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat("EEE, dd MMM yyyy").format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.cardBackground,
        elevation: 0,
        title: const Text(
          'Urban Advertising – Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String name = prefs.getString("admin_name") ?? "Admin";
            String email = prefs.getString("admin_email") ?? "admin@gmail.com";

            AttendanceService.markAttendance(
              context: context,
              name: name,
              email: email,
              role: "admin",
            );
          },
          label: const Text(
            'Mark Attendance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.fingerprint_rounded),
          backgroundColor: AppColors1.primaryAccent, // ✅ Works
          foregroundColor: Colors.white,
        ),

        body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== HERO / OVERVIEW CARD ==================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                    color: AppColors1.primaryAccent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Good to see you, Admin 👋",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Today’s Operations Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todayStr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.insights_outlined,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Track bookings, assign employees, and manage daily shoots from one place.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ================== STATUS CARDS ==================
            _buildSectionHeader("Today’s Booking Status"),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    label: "Upcoming",
                    status: "approved",
                    stream: _countByStatus("approved"),
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    label: "Pending",
                    status: "pending",
                    stream: _countByStatus("pending"),
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusCard(
                    label: "Completed",
                    status: "done",
                    stream: _countByStatus("done"),
                    color: AppColors1.primaryAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ================== QUICK ACTIONS GRID ==================
            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(context),

            const SizedBox(height: 24),

            // ================== CALENDAR ==================
            _buildSectionHeader("Booking Calendar"),
            const SizedBox(height: 8),
            _buildCalendar(),

            const SizedBox(height: 22),

            // ================== WEEKLY BOOKINGS ==================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader("This Week's Bookings"),
                _buildFilterMenu(),
              ],
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: _allBookingsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final weeklyDocs = _filterWeeklyDocs(docs);

                if (weeklyDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No bookings for this filter.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: weeklyDocs.length,
                  itemBuilder: (context, index) =>
                      _buildBookingCard(context, weeklyDocs[index]),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ================== BOTTOM NAV ==================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors1.cardBackground,
        selectedItemColor: AppColors1.primaryAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }

  // =============== REUSABLE UI HELPERS ===============

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // QUICK ACTIONS GRID
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        "label": "Customers",
        "icon": Icons.people_alt_outlined,
        "color": Colors.tealAccent,
        "page": const AdminCustomersScreen(),
      },
      {
        "label": "Employees",
        "icon": Icons.engineering_outlined,
        "color": Colors.orangeAccent,
        "page": const AdminEmployeesScreen(),
      },
      {
        "label": "Settings",
        "icon": Icons.settings_outlined,
        "color": Colors.blueAccent,
        "page": const AdminSettingsScreen(),
      },
      {
        "label": "Revenue",
        "icon": Icons.bar_chart_rounded,
        "color": Colors.purpleAccent,
        "page": const AdminRevenueScreen(),
      },
      {
        "label": "Attendance",
        "icon": Icons.fingerprint_rounded,
        "color": Colors.greenAccent,
        "page": const AdminAttendanceScreen(),
      },
      {
        "label": "Services",
        "icon": Icons.design_services_outlined,
        "color": Colors.amberAccent,
        "page": const AdminServicesScreen(),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => a["page"] as Widget),
            );
          },
          child: _buildActionButton(
            a["icon"] as IconData,
            a["label"] as String,
            a["color"] as Color,
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  // =========================== FILTER MENU ===========================

  Widget _buildFilterMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      color: AppColors1.cardBackground,
      onSelected: (value) {
        setState(() {
          _selectedFilter = value;
        });
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'upcoming',
          child: Text('Upcoming', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'pending',
          child: Text('Pending', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'done',
          child: Text('Done', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // =========================== NAV TAP ===========================

  Future<void> _onNavTap(int index) async {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAddOrderScreen()),
      );
    } else if (index == 2) {
      // 🔥 SHOW LOGOUT CONFIRMATION DIALOG
      bool? confirmLogout = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        ),
      );

      // If user pressed "Logout"
      if (confirmLogout == true) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  // =========================== CALENDAR ===========================

  Widget _buildCalendar() {
    if (isCalendarLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors1.primaryAccent),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
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

          final events = _getEventsForDay(selected);
          if (events.isNotEmpty) _showEventsBottomSheet(events);
        },
        eventLoader: (day) => _getEventsForDay(day),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white70),
          weekendStyle: TextStyle(color: Colors.white70),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white70),
          todayDecoration: BoxDecoration(
            color: AppColors1.secondaryAccent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors1.primaryAccent,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors1.primaryAccentLight,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _showEventsBottomSheet(List<Map<String, dynamic>> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors1.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  title: Text(
                    e["customer_name"] ?? "Unknown",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${e["time"] ?? "-"} • ${e["service"] ?? "-"}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70),
                )
            ],
          ),
        );
      },
    );
  }

  // ================== UPDATE STATUS ==================

  Future<void> _updateStatus(
      BuildContext context, String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection("slot_request")
          .doc(docId)
          .update({"status": newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status updated to $newStatus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================== ASSIGN EMPLOYEE MODAL ==================

  void _showAssignEmployeeSheet(
      BuildContext context, String bookingId, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors1.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String? selectedEmployeeId;
        String? selectedEmployeeName;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assign Employee",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("employee")
                    .where("role", isEqualTo: "employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  final employees = snapshot.data!.docs;

                  if (employees.isEmpty) {
                    return const Text(
                      "No employees found.",
                      style: TextStyle(color: Colors.white70),
                    );
                  }

                  return StatefulBuilder(
                    builder: (context, setStateSB) {
                      return DropdownButtonFormField<String>(
                        dropdownColor: AppColors1.cardBackground,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          labelText: "Select Employee",
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors1.primaryAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: employees.map((e) {
                          final empData = e.data() as Map<String, dynamic>;
                          final name = empData["name"] ?? "Unnamed";

                          return DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;

                          final empDoc =
                          employees.firstWhere((element) => element.id == val);
                          final empData =
                          empDoc.data() as Map<String, dynamic>;

                          setStateSB(() {
                            selectedEmployeeId = val;
                            selectedEmployeeName =
                                empData["name"] ?? "Employee";
                          });
                        },
                        value: selectedEmployeeId,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    if (selectedEmployeeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select an employee"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection("slot_request")
                        .doc(bookingId)
                        .update({
                      "assigned_employee_id": selectedEmployeeId,
                      "assigned_employee_name": selectedEmployeeName,
                      "status": "approved",
                    });

                    final empDoc = await FirebaseFirestore.instance
                        .collection("employee")
                        .doc(selectedEmployeeId)
                        .get();

                    final empToken = empDoc["fcmToken"];

                    if (empToken != null && empToken.isNotEmpty) {
                      await PushNotificationService.sendNotification(
                        token: empToken,
                        title: "New Task Assigned",
                        body:
                        "You have a new booking on ${booking["date"]} at ${booking["time"]}.",
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Employee assigned successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Assign"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================== BOOKING CARD ==================

  Widget _buildBookingCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = (data["status"] ?? "pending").toString().toLowerCase();
    final assignedEmp = data["assigned_employee_id"];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminBookingDetailsScreen(
              data: data,
              docId: doc.id,
            ),
          ),
        );
      },
      child: Card(
        color: AppColors1.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data["customer_name"] ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "Service: ${data["service"] ?? "-"}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "Date: ${data["date"] ?? "-"} | Time: ${data["time"] ?? "-"}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "Place: ${data["location"] ?? "-"}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 6),

              if (data["assigned_employee_name"] != null)
                Text(
                  "Assigned to: ${data["assigned_employee_name"]}",
                  style: const TextStyle(
                      color: Colors.greenAccent, fontSize: 13),
                ),

              const SizedBox(height: 10),

              // BUTTON LOGIC (unchanged)
              if (status == "pending" && assignedEmp == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateStatus(context, doc.id, "approved"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Approve"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateStatus(context, doc.id, "rejected"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      _showAssignEmployeeSheet(context, doc.id, data),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors1.primaryAccent),
                  child: const Text("Assign Employee"),
                ),
              ],
              if (status == "approved" && assignedEmp == null) ...[
                ElevatedButton(
                  onPressed: () =>
                      _showAssignEmployeeSheet(context, doc.id, data),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors1.primaryAccent),
                  child: const Text("Assign Employee"),
                ),
              ],
              if (status == "approved" && assignedEmp != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _updateStatus(context, doc.id, "done"),
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white70, size: 16),
                    label: const Text(
                      "Mark as Done",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// STATUS CARD WIDGET
// =========================

class _StatusCard extends StatelessWidget {
  final String label;
  final String status;
  final Stream<int> stream;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.status,
    required this.stream,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors1.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                "$count",
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
