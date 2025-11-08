import 'package:flutter/material.dart';
import 'package:urban_application/core/theme.dart';
import 'package:urban_application/screens/auth/login_screen.dart';
import 'package:urban_application/screens/auth/register_screen.dart';
import 'package:urban_application/home/home_screen.dart';
import 'package:urban_application/home/subscription_screen.dart';
import 'package:urban_application/home/payment_screen.dart';
import 'package:urban_application/home/success_screen.dart';
import 'package:urban_application/profile/profile_screen.dart';
import 'package:urban_application/profile/edit_profile_screen.dart';
import 'package:urban_application/bookings/bookings_screen.dart';
import 'package:urban_application/bookings/booking_success_screen.dart';
import 'package:urban_application/bookings/cancel_booking_screen.dart';
import 'package:urban_application/bookings/slot_booking_screen.dart';

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
        '/success': (context) => const SuccessScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/editProfile': (context) => const EditProfileScreen(),
        '/bookings': (context) => const BookingsScreen(),
        '/slot_booking': (context) => const SlotBookingScreen(),
        '/booking_success': (context) => const BookingSuccessScreen(),
        '/cancel_booking': (context) => const CancelBookingScreen(),

      },

    );
  }
}