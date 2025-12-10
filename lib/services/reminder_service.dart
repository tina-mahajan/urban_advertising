import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_service.dart';

class ReminderService {
  /// ============================================================
  /// 🔍 FLEXIBLE DATE PARSER (SUPPORTS ALL FORMATS)
  /// ============================================================
  static DateTime _parseDateFlexible(String dateStr) {
    if (dateStr.isEmpty) return DateTime(1900);

    final formats = [
      "dd MMM yyyy",
      "d MMM yyyy",
      "dd MMMM yyyy",
      "d MMMM yyyy",
    ];

    for (var f in formats) {
      try {
        return DateFormat(f).parse(dateStr);
      } catch (_) {}
    }

    print("❌ Unknown date format: $dateStr");
    return DateTime(1900);
  }

  /// ============================================================
  /// 🔔 EMPLOYEE REMINDER - 1 DAY BEFORE
  /// ============================================================
  static Future<void> sendEmployeeTomorrowReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("uid");
    final role = prefs.getString("role");

    if (uid == null || role != "employee") return;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final reminderKey = "emp_reminder_${uid}_${tomorrow.toString().substring(0, 10)}";

    if (prefs.getBool(reminderKey) == true) return;

    // Fetch all approved bookings
    final snapshot = await FirebaseFirestore.instance
        .collection("slot_request")
        .where("assigned_employee_id", isEqualTo: uid)
        .where("status", isEqualTo: "approved")
        .get();

    final tomorrowBookings = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _parseDateFlexible(data["date"] ?? "");

      return date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day;
    }).toList();

    if (tomorrowBookings.isEmpty) return;

    // Get employee FCM token
    final empDoc = await FirebaseFirestore.instance
        .collection("employee")
        .doc(uid)
        .get();

    final token = empDoc.data()?["fcmToken"];
    if (token == null || token.isEmpty) return;

    final first = tomorrowBookings.first.data() as Map<String, dynamic>;
    final count = tomorrowBookings.length;
    final service = first["service"] ?? "";
    final time = first["time"] ?? "";

    await PushNotificationService.sendNotification(
      token: token,
      title: "📅 Tomorrow's Bookings",
      body: "You have $count booking(s) tomorrow. First: $service at $time.",
    );

    await prefs.setBool(reminderKey, true);
  }

  /// ============================================================
  /// 🔔 ADMIN REMINDER - 1 DAY BEFORE
  /// ============================================================
  static Future<void> sendAdminTomorrowReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("uid");
    final role = prefs.getString("role");

    if (uid == null || role != "admin") return;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final reminderKey = "admin_reminder_${uid}_${tomorrow.toString().substring(0, 10)}";

    if (prefs.getBool(reminderKey) == true) return;

    // Fetch all approved bookings
    final snapshot = await FirebaseFirestore.instance
        .collection("slot_request")
        .where("status", isEqualTo: "approved")
        .get();

    final tomorrowBookings = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _parseDateFlexible(data["date"] ?? "");

      return date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day;
    }).toList();

    if (tomorrowBookings.isEmpty) return;

    // Fetch admin token
    final adminDoc = await FirebaseFirestore.instance
        .collection("admin")
        .doc(uid)
        .get();

    final token = adminDoc.data()?["fcmToken"];
    if (token == null || token.isEmpty) return;

    await PushNotificationService.sendNotification(
      token: token,
      title: "📅 Tomorrow’s Orders",
      body:
      "You have ${tomorrowBookings.length} approved booking(s) scheduled tomorrow.",
    );

    await prefs.setBool(reminderKey, true);
  }
}
