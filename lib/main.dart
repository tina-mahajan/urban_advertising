import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/screens/auth/login_screen.dart';
import 'package:urban_advertising/screens/auth/register_screen.dart';
import 'package:urban_advertising/home/home_screen.dart';
import 'package:urban_advertising/home/subscription_screen.dart';
import 'package:urban_advertising/home/payment_screen.dart';
import 'package:urban_advertising/home/success_screen.dart';
import 'package:urban_advertising/profile/profile_screen.dart';
import 'package:urban_advertising/profile/edit_profile_screen.dart';
import 'package:urban_advertising/bookings/bookings_screen.dart';
import 'package:urban_advertising/bookings/booking_success_screen.dart';
import 'package:urban_advertising/bookings/cancel_booking_screen.dart';
import 'package:urban_advertising/bookings/slot_booking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Advertising',

      // ✅ Add Poppins font globally here
      theme: appTheme,
      // initial page
      initialRoute: '/login',

      // All app routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/payment': (context) => const PaymentScreen(
          planName: '',
          planPrice: '',
        ),
        '/success': (context) {
          final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          return SuccessScreen(
            planName: args?['planName'] ?? '',
            planPrice: args?['planPrice'] ?? '',
            userName: args?['userName'] ?? '',
            paymentDate: args?['paymentDate'] ?? '',
          );
        },
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/bookings': (context) => const BookingsScreen(),
        '/slot_booking': (context) => const SlotBookingScreen(),

        '/booking_success': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<String, dynamic> &&
              args.containsKey('time') &&
              args.containsKey('date')) {
            return BookingSuccessScreen(
              bookedTime: args['time'] as String,
              bookedDate: args['date'] as DateTime,
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
