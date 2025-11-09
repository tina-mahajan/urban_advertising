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
import 'package:urban_advertising/bookings/booking_success_screen.dart'; // Make sure this file exists and contains the class
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
      theme: appTheme,


      // initial page
      initialRoute: '/login',

      // All app routes
      routes: {
        '/login': (context) => const LoginScreen(),
        // Note: '/register' is imported but missing here. Consider adding:
        // '/register': (context) => const RegisterScreen(),
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

        // ✅ FIXED: Route handler to read and pass runtime arguments
        '/booking_success': (context) {
          // 1. Retrieve arguments from the route settings
          final args = ModalRoute.of(context)?.settings.arguments;

          // 2. Check and safely cast the arguments (expecting a Map<String, dynamic>)
          if (args is Map<String, dynamic> && args.containsKey('time') && args.containsKey('date')) {
            // 3. Return the screen, passing the required runtime arguments
            return BookingSuccessScreen(
              bookedTime: args['time'] as String,
              bookedDate: args['date'] as DateTime,
            );
          }

          // 4. Fallback in case of an error or missing arguments
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