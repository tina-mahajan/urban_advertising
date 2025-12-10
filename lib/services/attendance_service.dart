import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  static Future<void> markAttendance({
    required BuildContext context,
    required String name,
    required String email,
    required String role, // admin OR employee
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User ID not found!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String today = DateTime.now().toIso8601String().substring(0, 10);
    String timeNow = TimeOfDay.now().format(context);

    final docRef = FirebaseFirestore.instance
        .collection("attendance")
        .doc(uid)
        .collection("records")
        .doc(today);

    final doc = await docRef.get();

    if (!doc.exists) {
      // MARK IN TIME
      await docRef.set({
        "uid": uid,
        "name": name,
        "email": email,
        "role": role,
        "date": today,
        "in_time": timeNow,
        "out_time": "",
        "status": "Present",
        "created_at": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance Marked (IN)"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // MARK OUT TIME
      await docRef.update({
        "out_time": timeNow,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance Marked (OUT)"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
