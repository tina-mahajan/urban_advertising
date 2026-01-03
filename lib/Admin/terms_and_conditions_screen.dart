import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('1. Acceptance of Terms'),
            _SectionText(
              'By accessing or using the Urban Advertising application, you agree '
                  'to comply with and be bound by these Terms & Conditions. '
                  'If you do not agree, please do not use the app.',
            ),

            _SectionTitle('2. Services'),
            _SectionText(
              'Urban Advertising provides services related to bookings, '
                  'photography, videography, editing, and delivery management. '
                  'Service availability may change without prior notice.',
            ),

            _SectionTitle('3. User Accounts'),
            _SectionText(
              'You are responsible for maintaining the confidentiality of your '
                  'account credentials. Any activity under your account is your responsibility.',
            ),

            _SectionTitle('4. Bookings & Payments'),
            _SectionText(
              'All bookings are subject to availability. Payments once made '
                  'are non-refundable unless explicitly stated. Urban Advertising '
                  'is not responsible for delays caused by unavoidable circumstances.',
            ),

            _SectionTitle('5. Content Ownership'),
            _SectionText(
              'All photos, videos, and creative content produced by Urban Advertising '
                  'remain the property of Urban Advertising unless otherwise agreed in writing.',
            ),

            _SectionTitle('6. Prohibited Activities'),
            _SectionText(
              'You agree not to misuse the app, attempt unauthorized access, '
                  'or engage in activities that may harm the platform or other users.',
            ),

            _SectionTitle('7. Account Termination'),
            _SectionText(
              'Urban Advertising reserves the right to suspend or terminate accounts '
                  'that violate these terms without prior notice.',
            ),

            _SectionTitle('8. Privacy'),
            _SectionText(
              'Your personal data is handled according to our Privacy Policy. '
                  'We do not sell or misuse user information.',
            ),

            _SectionTitle('9. Limitation of Liability'),
            _SectionText(
              'Urban Advertising shall not be liable for any indirect, incidental, '
                  'or consequential damages arising from the use of this app.',
            ),

            _SectionTitle('10. Changes to Terms'),
            _SectionText(
              'We may update these Terms & Conditions from time to time. '
                  'Continued use of the app means you accept the updated terms.',
            ),

            SizedBox(height: 24),

            Center(
              child: Text(
                '© Urban Advertising. All rights reserved.',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Section Title Widget
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

/// 🔹 Section Content Widget
class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        height: 1.6,
        fontFamily: 'Poppins',
      ),
    );
  }
}
