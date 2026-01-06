import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/core/theme.dart';

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

      if (uid == null) return;

      // 🔥 Fetch real employee data from Firestore
      final empDoc = await FirebaseFirestore.instance
          .collection("employee")
          .doc(uid)
          .get();

      final name = empDoc["name"] ?? "";
      final role = empDoc["role"] ?? "employee";

      await FirebaseFirestore.instance
          .collection("problem_reports") // auto-created
          .add({
        "employeeId": uid,
        "employeeName": name,      // ✅ correct name now
        "role": role,
        "problemType": selectedProblem,
        "description": descriptionController.text.trim(),
        "status": "open",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Problem reported successfully")),
      );

      Navigator.pop(context);
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Report Problem"),
        backgroundColor: AppColors1.cardBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Problem Type",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
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
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors1.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Describe the problem...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppColors1.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitProblem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors1.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Problem",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
