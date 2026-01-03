import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Security Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _securityTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your login password',
            onTap: () {
              // Navigate to ChangePasswordScreen
            },
          ),
          _securityTile(
            icon: Icons.devices_other,
            title: 'Logout from all devices',
            subtitle: 'Secure your account',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All sessions will be cleared'),
                ),
              );
            },
          ),
          _securityTile(
            icon: Icons.verified_user,
            title: 'Security Status',
            subtitle: 'Your account is secure',
            isStatus: true,
          ),
        ],
      ),
    );
  }

  Widget _securityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isStatus = false,
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
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: isStatus
            ? const Icon(Icons.check_circle, color: Colors.greenAccent)
            : const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.white70),
      ),
    );
  }
}
