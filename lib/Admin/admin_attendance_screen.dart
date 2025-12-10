import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  bool loading = true;
  List<Map<String, dynamic>> attendanceList = [];

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    List<Map<String, dynamic>> finalList = [];

    try {
      debugPrint("STEP 1: Fetching attendance users...");
      QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection("attendance").get();

      debugPrint("Found ${usersSnapshot.docs.length} users");

      for (var user in usersSnapshot.docs) {
        String uid = user.id;

        CollectionReference recordsRef = FirebaseFirestore.instance
            .collection("attendance")
            .doc(uid)
            .collection("records");

        QuerySnapshot dateDocs = await recordsRef.get();

        debugPrint("User $uid has ${dateDocs.docs.length} date entries");

        for (var dateDoc in dateDocs.docs) {
          var raw = dateDoc.data() as Map<String, dynamic>;

          // CASE 1 → Date document already contains fields
          if (raw.containsKey("name") && raw.containsKey("in_time")) {
            raw["uid"] = uid;
            raw["record_id"] = dateDoc.id;
            finalList.add(raw);
          } else {
            // CASE 2 → Date doc contains nested subcollection
            QuerySnapshot nested =
            await recordsRef.doc(dateDoc.id).collection("records").get();

            for (var rec in nested.docs) {
              var data = rec.data() as Map<String, dynamic>;

              data["uid"] = uid;
              data["record_id"] = dateDoc.id;

              finalList.add(data);
            }
          }
        }
      }

      debugPrint("STEP 3: Sorting final list…");

      finalList.sort((a, b) {
        DateTime da = DateTime.tryParse(a["date"] ?? "") ?? DateTime(2000);
        DateTime db = DateTime.tryParse(b["date"] ?? "") ?? DateTime(2000);
        return db.compareTo(da);
      });

      debugPrint("FINAL LIST LENGTH = ${finalList.length}");

      setState(() {
        attendanceList = finalList;
        loading = false;
      });
    } catch (e) {
      debugPrint("ERROR LOADING ATTENDANCE = $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.cardBackground,
        title: const Text("Attendance Records",
            style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : attendanceList.isEmpty
          ? const Center(
        child: Text(
          "No attendance records found",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final data = attendanceList[index];

          String date = data["date"] ?? "-";
          String name = data["name"] ?? "Unknown";
          String inTime = data["in_time"] ?? "-";
          String outTime =
          (data["out_time"] == null || data["out_time"] == "")
              ? "-"
              : data["out_time"];

          return Card(
            color: AppColors1.cardBackground,
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Date: $date\nIN: $inTime\nOUT: $outTime",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
