import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';
import 'package:urban_advertising/Employee/profile/emp_settings.dart';
import 'package:urban_advertising/Employee/profile/emp_edit_profile.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  String name = "";
  String email = "";
  String phone = "";
  String designation = "";
  String joinedDate = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");

      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection("employee").doc(uid).get();

      if (doc.exists) {
        Timestamp ts = doc["created_at"];
        DateTime dt = ts.toDate();
        joinedDate = DateFormat("d MMMM yyyy").format(dt);

        setState(() {
          name = doc["name"] ?? "";
          email = doc["email"] ?? "";
          phone = doc["phone"].toString();
          designation = doc["designation"] ?? doc["role"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  Widget buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors1.divider),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,

      // ------------------- APP BAR ----------------------
      appBar: AppBar(
        backgroundColor: AppColors1.darkBackground,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors1.textLight,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors1.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors1.textLight),
            onPressed: () {
              Navigator.pushNamed(context, "/emp_settings");
            },
          ),
        ],
      ),

      // ------------------- BODY ----------------------
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors1.primaryAccent))
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER PROFILE CARD ==========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: AppColors1.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors1.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ---------- USER ICON CENTER + EDIT ICON RIGHT ----------
                  Stack(
                    children: [
                      // CENTERED USER ICON
                      Align(
                        alignment: Alignment.center,
                        child: const CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                      ),

                      // EDIT ICON (RIGHT SIDE)
                      Positioned(
                        right: 0,
                        top: 12,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeEditProfileScreen(
                                  name: name,
                                  email: email,
                                  phone: phone,
                                  designation: designation,
                                  // if you store it
                                ),
                              ),
                            );
                          },

                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors1.cardBackground.withOpacity(0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors1.textLight,
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: AppColors1.textLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // -------- USER NAME --------
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors1.textLight,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // -------- DESIGNATION --------
                  Text(
                    designation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors1.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),


            // PERSONAL INFO
            const Text(
              "Personal Info",
              style: TextStyle(
                color: AppColors1.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow("Email:", email),
                  infoRow("Contact:", phone),
                  infoRow("Role:", designation),
                  infoRow("Joined:", joinedDate),
                ],
              ),
            ),

            // ACTIVITY
            const Text(
              "Activity",
              style: TextStyle(
                color: AppColors1.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  infoRow("Total Tasks:", "4"),
                  infoRow("Completed Tasks:", "3"),
                ],
              ),
            ),

            // MY CONTENT
            const Text(
              "My Content",
              style: TextStyle(
                color: AppColors1.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  contentRow(Icons.video_library, "My Videos"),
                  contentRow(Icons.history, "Bookings History"),
                  contentRow(Icons.favorite_border, "Saved Items"),
                ],
              ),
            ),
          ],
        ),
      ),

      // ------------------- BOTTOM NAV BAR ----------------------
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Profile Selected
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, "/emp_home");
          } else if (index == 1) {
            Navigator.pushNamed(context, "/emp_slots");
          } else if (index == 2) {
            Navigator.pushNamed(context, "/clients");
          } else if (index == 3) {
            // Already here
          }
        },
      ),
    );
  }
}

// ========== REUSABLE ROWS ==============

class infoRow extends StatelessWidget {
  final String label;
  final String value;

  const infoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors1.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors1.textLight,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class contentRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const contentRow(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors1.secondaryAccent, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors1.textLight,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
