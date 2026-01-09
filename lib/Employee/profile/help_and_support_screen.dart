import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 24),

          _sectionTitle('Frequently Asked Questions'),
          _faqTile(
            question: 'How do I book a service?',
            answer:
            'Go to the Book Slot section, select your service, choose date & time, and confirm your booking.',
          ),
          _faqTile(
            question: 'How can I track my booking status?',
            answer:
            'You can track booking status from the Bookings section where updates like Approved, Shooting, Editing, and Delivered are shown.',
          ),
          _faqTile(
            question: 'How do I contact support?',
            answer:
            'You can contact us using the support options below such as email or phone.',
          ),
          _faqTile(
            question: 'What if my payment fails?',
            answer:
            'If payment fails, please retry or contact support with transaction details.',
          ),

          const SizedBox(height: 24),

          _sectionTitle('Contact Support'),
          _supportCard(
            icon: Icons.email_outlined,
            title: 'Email Us',
            subtitle: 'support@urbanadvertising.com',
            onTap: () {
              // later: open email app
            },
          ),
          _supportCard(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+91 90000 00000',
            onTap: () {
              // later: launch phone dialer
            },
          ),
          _supportCard(
            icon: Icons.location_on_outlined,
            title: 'Office Address',
            subtitle: 'Pune, Maharashtra, India',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'We usually respond within 24 hours.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E40C2), Color(0xFF5CC8FF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.support_agent, color: Colors.white, size: 34),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Need help?\nWe’re here to support you.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _faqTile({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 14.5,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white70,
        ),
      ),
    );
  }
}
