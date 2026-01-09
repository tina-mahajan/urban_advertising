import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/core/theme.dart';

// YOUR EXISTING NOTIFICATION SERVICE
import '../../services/push_notification_service.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController descriptionController = TextEditingController();

  String selectedProblem = "Client Issue";
  bool isSubmitting = false;

  final List<String> problemTypes = [
    "Client Issue",
    "Location Issue",
    "Equipment Problem",
    "Network / Upload Issue",
    "Other",
  ];

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: AppColors1.cardBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
      ),
    );
  }

  Future<void> submitProblem() async {
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter problem description")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString("uid");

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again")),
        );
        return;
      }

      // Fetch employee document
      final empDoc = await FirebaseFirestore.instance
          .collection("employee")
          .doc(uid)
          .get();

      if (!empDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee record not found")),
        );
        return;
      }

      final String name = (empDoc.data()?["name"] ?? "").toString();

      // Save report
      await FirebaseFirestore.instance
          .collection("problem_reports")
          .add({
        "employeeId": uid,
        "employeeName": name,
        "problemType": selectedProblem,
        "description": descriptionController.text.trim(),
        "status": "open",
        "createdAt": FieldValue.serverTimestamp(),
      });

      descriptionController.clear();

      // NOTIFY ALL ADMINS
      await notifyAdmins(name, selectedProblem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Problem reported successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // CALL YOUR EXISTING SERVICE FOR ADMIN NOTIFICATION
  Future<void> notifyAdmins(String empName, String problemType) async {
    try {
      // FETCH ADMIN TOKENS FROM ADMIN COLLECTION
      final adminsSnapshot = await FirebaseFirestore.instance
          .collection("admin")
          .get();

      for (var doc in adminsSnapshot.docs) {
        final token = doc.data()["fcmToken"];

        if (token == null || token.toString().isEmpty) continue;

        await PushNotificationService.sendNotification(
          token: token.toString(),
          title: "New Problem Report",
          body: "$empName reported: $problemType",
        );
      }
    } catch (e) {
      print("❌ Admin Notification Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Report Problem"),
        backgroundColor: AppColors1.cardBackground,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Select Problem Type",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedProblem,
              dropdownColor: AppColors1.cardBackground,
              items: problemTypes
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedProblem = val!);
              },
              decoration: _inputDecoration("Problem Type"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Problem Description",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Describe the problem..."),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : submitProblem,
                icon: const Icon(Icons.send),
                label: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Problem"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors1.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
