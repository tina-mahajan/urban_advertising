import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:urban_advertising/core/theme.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  String searchText = "";

  // ================= HELPERS =================

  Timestamp? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    return null;
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return "-";
    return DateFormat('hh:mm a').format(ts.toDate());
  }

  String _workedHours(Timestamp? inTs, Timestamp? outTs) {
    if (inTs == null || outTs == null) return "-";
    final diff = outTs.toDate().difference(inTs.toDate());
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  // ================= PDF EXPORT =================

  Future<void> _exportPdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Attendance Report",
                  style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              ...docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return pw.Text(
                  "${d["date"]} | ${d["name"]} | ${(d["worked_minutes"] ?? 0) ~/ 60} hrs",
                );
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ================= MONTHLY SUMMARY =================

  Widget _buildMonthlySummary(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    int totalMinutes = 0;
    final Set<String> uniqueDays = {}; // 🔥 FIX

    for (var doc in docs) {
      final d = doc.data() as Map<String, dynamic>;
      final date = d["date"] ?? "";

      if (date.startsWith(monthKey) &&
          d["in_time"] != null &&
          d["out_time"] != null) {
        uniqueDays.add(date); // ✅ count unique day only
        totalMinutes += (d["worked_minutes"] ?? 0) as int;
      }
    }

    return Card(
      color: AppColors1.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem("Days", uniqueDays.length.toString()),
            _summaryItem(
              "Hours",
              "${totalMinutes ~/ 60}h ${totalMinutes % 60}m",
            ),
          ],
        ),
      ),
    );
  }


  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: AppColors1.cardBackground,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup("records")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          final allDocs = snapshot.data!.docs;

          // 🔍 SEARCH FILTER
          final filteredDocs = allDocs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final name = (d["name"] ?? "").toString().toLowerCase();
            return name.contains(searchText.toLowerCase());
          }).toList();

          return Column(
            children: [
              // 🔹 SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(12),
                child:TextField(
                  onChanged: (val) => setState(() => searchText = val),
                  style: const TextStyle(color: Colors.white), // ✅ typed text color
                  decoration: InputDecoration(
                    hintText: "Search employee...",
                    hintStyle: const TextStyle(
                      color: Colors.white70, // ✅ hint text color
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white, // ✅ search icon color
                    ),
                    filled: true,
                    fillColor: AppColors1.cardBackground,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors1.primaryAccent),
                    ),
                  ),
                ),

              ),

              // // 🔹 MONTHLY SUMMARY
              // _buildMonthlySummary(filteredDocs),

              // 🔹 EXPORT BUTTON
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: () => _exportPdf(filteredDocs),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                  ),
                ),
              ),

              // 🔹 ATTENDANCE LIST (UNCHANGED LOGIC)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                    filteredDocs[index].data() as Map<String, dynamic>;

                    final name = data["name"] ?? "Unknown";
                    final role = data["role"] ?? "-";
                    final date = data["date"] ?? "-";

                    final inTime = _parseTimestamp(data["in_time"]);
                    final outTime = _parseTimestamp(data["out_time"]);

                    return Card(
                      color: AppColors1.cardBackground,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text(role.toUpperCase(),
                                    style: TextStyle(
                                        color: role == "admin"
                                            ? Colors.purpleAccent
                                            : Colors.greenAccent)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Date: $date",
                                style: const TextStyle(
                                    color: Colors.white70)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                _info("IN", _formatTime(inTime)),
                                _info("OUT", _formatTime(outTime)),
                                _info("HOURS",
                                    _workedHours(inTime, outTime)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11)),
        Text(value,
            style:
            const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
