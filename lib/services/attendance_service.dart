import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class AttendanceService {
  // ============================================================
  // 🔐 BIOMETRIC AUTHENTICATION (ANDROID + IOS)
  // ============================================================
  static Future<bool> _authenticateBiometric(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final bool isSupported = await auth.isDeviceSupported();

      if (!isSupported) {
        _show(context, "Biometric not supported on this device ❌");
        return false;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: "Verify your identity to mark attendance",
        options: const AuthenticationOptions(
          biometricOnly: false, // 🔥 allow PIN / pattern fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!authenticated) {
        _show(context, "Biometric authentication cancelled ❌");
      }

      return authenticated;
    } catch (e) {
      debugPrint("BIOMETRIC EXCEPTION: $e");
      _show(context, "Biometric authentication failed ❌");
      return false;
    }
  }



  // ============================================================
  // 📍 MAIN ATTENDANCE METHOD
  // ============================================================
  static Future<void> markAttendance({
    required BuildContext context,
    required String name,
    required String email,
    required String role, // admin / employee
  }) async {
    try {
      // ===============================
      // 1️⃣ AUTH CHECK
      // ===============================
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _show(context, "User not logged in ❌");
        return;
      }

      final uid = user.uid;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final now = Timestamp.now();

      // ===============================
      // 2️⃣ LOCATION PERMISSION
      // ===============================
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _show(context, "Enable location services ❌");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _show(context, "Location permission denied permanently ❌");
        return;
      }

      // ===============================
      // 3️⃣ GET LOCATION
      // ===============================
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 🏢 OFFICE LOCATION (Dighi - Shiv Nagari)
      const double officeLat = 18.621309;
      const double officeLng = 73.8662279;
      const double allowedRadius = 500; // meters

      final distance = Geolocator.distanceBetween(
        officeLat,
        officeLng,
        position.latitude,
        position.longitude,
      );

      if (distance > allowedRadius) {
        _show(context, "You are outside office area ❌");
        return;
      }

      // ===============================
      // 4️⃣ BIOMETRIC AUTHENTICATION
      // ===============================
      final isAuthenticated = await _authenticateBiometric(context);
      if (!isAuthenticated) return;

      // ===============================
      // 5️⃣ DEVICE ID (ANTI-PROXY)
      // ===============================
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = "unknown";

      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await deviceInfo.androidInfo;
        deviceId = android.id ?? "android";
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId = ios.identifierForVendor ?? "ios";
      }

      // ===============================
      // 6️⃣ FIRESTORE REF
      // ===============================
      final docRef = FirebaseFirestore.instance
          .collection("attendance")
          .doc(uid)
          .collection("records")
          .doc(today);

      final snap = await docRef.get();

      // ===============================
      // ✅ FIRST TAP → IN
      // ===============================
      if (!snap.exists) {
        await docRef.set({
          "uid": uid,
          "name": name,
          "email": email,
          "role": role,
          "date": today,

          "in_time": now,
          "out_time": null,

          "in_location": {
            "lat": position.latitude,
            "lng": position.longitude,
          },

          "device_id": deviceId,
          "status": "Present",
          "created_at": now,
        });

        _show(context, "Attendance IN marked ✅");
        return;
      }

      // ===============================
      // ✅ SECOND TAP → OUT
      // ===============================
      final data = snap.data()!;
      if (data["out_time"] != null) {
        _show(context, "Attendance already completed ⚠️");
        return;
      }

      final inTime = (data["in_time"] as Timestamp).toDate();
      final workedMinutes =
          DateTime.now().difference(inTime).inMinutes;

      await docRef.update({
        "out_time": now,
        "out_location": {
          "lat": position.latitude,
          "lng": position.longitude,
        },
        "worked_minutes": workedMinutes,
      });

      _show(context, "Attendance OUT marked ✅");
    } catch (e) {
      _show(context, "Attendance failed ❌");
    }
  }

  // ============================================================
  // 🔔 SNACKBAR HELPER
  // ============================================================
  static void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
