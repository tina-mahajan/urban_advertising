import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF0A0A0A); // Same as profile background
  static const Color cardSurface = Color(0xFF1A1A1A);    // Card background like profile boxes
  static const Color primaryAccent = Color(0xFF5A00FF);  // Purple accent
  static const Color secondaryAccent = Color(0xFFFFFFFF); // Yellow accent
  static const Color textLight = Colors.white;
  static const Color textMuted = Colors.white70;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentIndex = 3;
  bool _notificationsEnabled = true;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/slot_booking');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/subscription');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = AppColors.secondaryAccent,
    bool isDanger = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 60, // ✅ Fixed equal height for all items
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isDanger ? Colors.redAccent : AppColors.textLight,
                    fontSize: 15.5,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Account'),
          _buildCardGroup(
            children: [
              _buildSettingItem(
                icon: Icons.edit_note,
                title: 'Edit Profile',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.notifications_none,
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                  activeColor: AppColors.secondaryAccent,
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: Colors.white24,
                ),
              ),
            ],
          ),

          _buildSectionHeader('Support & About'),
          _buildCardGroup(
            children: [
              _buildSettingItem(
                icon: Icons.subscriptions_outlined,
                title: 'My Subscription',
                onTap: () => Navigator.pushNamed(context, '/subscription'),
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.support_agent,
                title: 'Help & Support',
                onTap: () {},
              ),
            ],
          ),


          _buildSectionHeader('Cache & Cellular'),
          _buildCardGroup(
            children: [
              _buildSettingItem(
                icon: Icons.delete_sweep_outlined,
                title: 'Free Up Space',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.data_saver_on_outlined,
                title: 'Data Saver',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear Cache',
                onTap: () {},
              ),
            ],
          ),


          _buildSectionHeader('Actions'),
          _buildCardGroup(
            children: [
              _buildSettingItem(
                icon: Icons.bug_report_outlined,
                title: 'Report a Problem',
                iconColor: AppColors.textMuted,
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Add Account',
                onTap: () {},
              ),
              Divider(color: Colors.white10, height: 1),
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.redAccent,
                isDanger: true,
                trailing:
                const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textLight,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.textMuted,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}
