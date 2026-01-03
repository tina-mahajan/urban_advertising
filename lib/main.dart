import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

// AUTH
import 'package:urban_advertising/screens/auth/login_screen.dart';
import 'package:urban_advertising/screens/auth/register_screen.dart';
import 'package:urban_advertising/screens/auth/auth_check_screen.dart';

// CUSTOMER
import 'package:urban_advertising/home/home_screen.dart';
import 'package:urban_advertising/home/subscription_screen.dart';
import 'package:urban_advertising/home/payment_screen.dart';
import 'package:urban_advertising/home/success_screen.dart';

// BOOKINGS
import 'package:urban_advertising/bookings/bookings_screen.dart';
import 'package:urban_advertising/bookings/slot_booking_screen.dart';
import 'package:urban_advertising/bookings/booking_success_screen.dart';
import 'package:urban_advertising/bookings/cancel_booking_screen.dart';

// PROFILE
import 'package:urban_advertising/profile/profile_screen.dart';

// EMPLOYEE
import 'package:urban_advertising/Employee/screens/emp_home_screen.dart';
import 'package:urban_advertising/Employee/screens/emp_slots.dart';
import 'package:urban_advertising/Employee/screens/clients_screen.dart';
import 'package:urban_advertising/Employee/screens/emp_client_profile.dart';
import 'package:urban_advertising/Employee/profile/employee_profile_screen.dart';
import 'package:urban_advertising/Employee/profile/emp_edit_profile.dart';
import 'package:urban_advertising/Employee/profile/emp_settings.dart';

// ADMIN
import 'package:urban_advertising/Admin/admin_dashboard_screen.dart';

// FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:urban_advertising/services/notification_service.dart';

// 🔥 ADDED (REQUIRED FOR TOKEN REFRESH)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔑 Global navigator key for popup notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 Background notification handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔥 Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔄 FCM TOKEN REFRESH HANDLER (CRITICAL FOR AUTO LOGIN)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("uid");
    final role = prefs.getString("role");

    if (uid == null || role == null) return;

    final collection = role == "admin"
        ? "admin"
        : role == "employee"
        ? "employee"
        : "Customer";

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .update({"fcmToken": newToken});

    print("🔄 FCM Token refreshed & saved");
  });

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Request permission (Android 13+)
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Foreground notification listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      LocalNotificationService.showNotification(
        title: notification.title ?? "",
        body: notification.body ?? "",
      );
    }
  });

  await LocalNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Urban Advertising',
      theme: appTheme,

      // ✅ AUTO LOGIN HANDLER
      home: const AuthCheckScreen(),

      routes: {
        // AUTH
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),

        // CUSTOMER
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/profile': (context) => const ProfileScreen(),

        // BOOKINGS
        '/slot_booking': (context) => const SlotBookingScreen(),
        '/bookings': (context) => const BookingsScreen(),
        '/cancel_booking': (context) => const CancelBookingScreen(),
        '/booking_success': (context) => BookingSuccessScreen(
          bookedTime: "",
          bookedDate: DateTime.now(),
        ),

        // PAYMENT
        '/payment_screen': (context) =>
        const PaymentScreen(planName: '', planPrice: ''),
        '/success': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;

          return SuccessScreen(
            planName: args?['planName'] ?? '',
            planPrice: args?['planPrice'] ?? '',
            userName: args?['userName'] ?? '',
            paymentDate: args?['paymentDate'] ?? '',
          );
        },

        // EMPLOYEE
        '/emp_home': (context) => const EmployeeHomeScreen(),
        '/emp_slots': (context) => const EmpSlotRequestsScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/employee_profile': (context) => const EmployeeProfileScreen(),
        '/emp_settings': (context) => const EmployeeSettingsScreen(),
        '/employee_edit_profile': (context) =>
        const EmployeeEditProfileScreen(
          name: "",
          email: "",
          phone: "",
          designation: "",
        ),

        '/emp_client_profile': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return EmpClientProfileScreen(
            clientId: args["clientId"],
            initialName: args["name"] ?? "",
            initialEmail: args["email"] ?? "",
            initialPhone: args["phone"] ?? "",
            initialAvatar: args["avatar"] ?? "",
          );
        },

        // ADMIN
        '/admin_dashboard': (context) =>
        const AdminDashboardScreen(),
      },
    );
  }
}
