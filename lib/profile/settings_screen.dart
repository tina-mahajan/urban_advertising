import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.textLight),
            title: const Text(
              'Change Password',
              style: TextStyle(color: AppColors.textLight), // ✅ textLight color applied
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // navigate to change password screen
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.notifications_none, color: AppColors.textLight),
            title: const Text('Notifications',
            style: TextStyle(color: AppColors.textLight),
            ),
            trailing: Switch(
              value: true,
              onChanged: (val) {
                // handle notification toggle
              },
              activeColor: AppColors.textLight,
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.language, color: AppColors.textLight),
            title: const Text('Language',
            style: TextStyle(color: AppColors.textLight),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // open language selection
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textLight),
            title: const Text('Privacy Policy',
            style: TextStyle(color: AppColors.textLight),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // open privacy policy
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.textLight),
            title: const Text('About Us',
            style: TextStyle(color: AppColors.textLight),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // open about us
            },
          ),
          const Divider(),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
