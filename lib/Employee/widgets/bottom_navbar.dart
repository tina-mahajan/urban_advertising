import 'package:flutter/material.dart';
import 'package:urban_advertising/Employee/screens/emp_home_screen.dart';

class AppColors {
  static const Color primaryAccent = Color(0xFF6E40C2);
  static const Color secondaryText = Color(0xFFC9D1D9);
  static const Color cardBackground = Color(0xFF161B22);
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.secondaryText,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Book Slot",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: "Clients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
