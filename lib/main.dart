import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/screens/auth/login_screen.dart';
import 'package:urban_advertising/screens/auth/register_screen.dart';
import 'package:urban_advertising/Employee/screens/emp_home_screen.dart';
import 'package:urban_advertising/home/subscription_screen.dart';
import 'package:urban_advertising/home/payment_screen.dart';
import 'package:urban_advertising/home/success_screen.dart';
import 'package:urban_advertising/profile/profile_screen.dart';
import 'package:urban_advertising/bookings/bookings_screen.dart';
import 'package:urban_advertising/bookings/booking_success_screen.dart';
import 'package:urban_advertising/bookings/cancel_booking_screen.dart';
import 'package:urban_advertising/bookings/slot_booking_screen.dart';
import 'package:urban_advertising/home/home_screen.dart';
import 'package:urban_advertising/Employee/profile/employee_profile_screen.dart';
import 'package:urban_advertising/Employee/profile/emp_settings.dart';
import 'package:urban_advertising/Employee/profile/emp_edit_profile.dart';
import 'package:urban_advertising/Employee/screens/emp_slots.dart';
import 'package:urban_advertising/Employee/screens/clients_screen.dart';
import 'package:urban_advertising/Employee/screens/emp_client_profile.dart';
import 'package:urban_advertising/Admin/admin_dashboard_screen.dart';



import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Advertising',
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
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
        '/profile': (context) => const ProfileScreen(),
        '/bookings': (context) => const BookingsScreen(),
        '/slot_booking': (context) => const SlotBookingScreen(),
        '/emp_home': (context) => const EmployeeHomeScreen(),
        '/employee_profile': (context) => const EmployeeProfileScreen(),
        '/emp_settings': (context) => const EmployeeSettingsScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/employee_edit_profile': (context) => const EmployeeEditProfileScreen(
          name: "",
          email: "",
          phone: "",
          designation: "",
        ),
        '/emp_slots': (context) => const EmpSlotRequestsScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/emp_client_profile': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return EmpClientProfileScreen(
            clientId: args["clientId"] as String,       // MUST exist
            initialName: args["name"] as String? ?? "",
            initialEmail: args["email"] as String? ?? "",
            initialPhone: args["phone"] as String? ?? "",
            initialAvatar: args["avatar"] as String? ?? "",
          );
        },






        '/booking_success': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return BookingSuccessScreen(
              bookedTime: args['time'],
              bookedDate: args['date'],
            );
          }
          return BookingSuccessScreen(
            bookedTime: 'Error loading time',
            bookedDate: DateTime.now(),
          );
        },
        '/cancel_booking': (context) => const CancelBookingScreen(),
      },
    );
  }
}
