import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';
import '../../core/theme.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  State<EmployeeSettingsScreen> createState() => _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState extends State<EmployeeSettingsScreen> {
  int currentIndex = 3;
  bool notificationsEnabled = true;

  void onTap(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/emp_home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/emp_slots');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/clients');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/employee_profile');
        break;
    }
  }

  // ---- Section Title ----
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---- Setting Card Container ----
  Widget settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: children),
    );
  }

  // ---- Single Setting Row ----
  Widget settingItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color iconColor = AppColors.textLight,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: danger ? Colors.redAccent : iconColor, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  color: danger ? Colors.redAccent : AppColors.textLight,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.white60),
          ],
        ),
      ),
    );
  }

  Divider line() => Divider(color: Colors.white10, height: 1);

  // ---- Logout Dialog ----
  void showLogoutPopup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors1.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout",
            style: TextStyle(color: AppColors.textLight)),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (route) => false);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // ---- MAIN BUILD ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,

      appBar: AppBar(
        backgroundColor: AppColors1.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ------ ACCOUNT ------
          sectionTitle("Account"),
          settingsCard([
            settingItem(
              icon: Icons.edit_note,
              title: "Edit Profile",
              onTap: () => Navigator.pushNamed(context, "/employee_profile"),
            ),
            line(),
            settingItem(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),
            line(),
            settingItem(
              icon: Icons.notifications_none,
              title: "Notifications",
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
                activeColor: AppColors1.secondaryAccent,
              ),
            ),
          ]),

          // ------ SUPPORT ------
          sectionTitle("Support"),
          settingsCard([
            settingItem(
              icon: Icons.support_agent,
              title: "Help & Support",
              onTap: () {},
            ),
            line(),
            settingItem(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              onTap: () {},
            ),
          ]),

          // ------ STORAGE ------
          sectionTitle("Storage"),
          settingsCard([
            settingItem(
              icon: Icons.delete_sweep_outlined,
              title: "Free Up Space",
              onTap: () {},
            ),
            line(),
            settingItem(
              icon: Icons.cleaning_services_outlined,
              title: "Clear Cache",
              onTap: () {},
            ),
          ]),

          // ------ DANGER SECTION ------
          sectionTitle("Actions"),
          settingsCard([
            settingItem(
              icon: Icons.bug_report_outlined,
              title: "Report a Problem",
              onTap: () {},
              iconColor: Colors.white70,
            ),
            line(),
            settingItem(
              icon: Icons.logout,
              title: "Logout",
              danger: true,
              onTap: showLogoutPopup,
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),

      bottomNavigationBar:
      CustomBottomNavBar(currentIndex: currentIndex, onTap: onTap),
    );
  }
}
