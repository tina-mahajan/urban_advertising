import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminGadgetResponsibilityScreen extends StatefulWidget {
  const AdminGadgetResponsibilityScreen({super.key});

  @override
  State<AdminGadgetResponsibilityScreen> createState() =>
      _AdminGadgetResponsibilityScreenState();
}

class _AdminGadgetResponsibilityScreenState
    extends State<AdminGadgetResponsibilityScreen> {

  String? selectedEmpId;
  String? selectedEmpName;

  final TextEditingController gadgetsController = TextEditingController();
  bool isSaving = false;

  // ================= CENTRAL INPUT DECORATION =================
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: AppColors1.cardBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors1.primaryAccent),
      ),
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat("dd MMM yyyy, hh:mm a")
        .format(timestamp.toDate());
  }

  // ================= FINAL ASSIGN GADGET LOGIC =================
  Future<void> assignGadgets() async {

    if (selectedEmpId == null ||
        selectedEmpName == null ||
        gadgetsController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select employee and enter gadgets")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {

      final List<String> newGadgets = gadgetsController.text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // CHECK EXISTING ASSIGNMENT FOR EMPLOYEE
      final existingSnapshot = await FirebaseFirestore.instance
          .collection("gadgets_responsibility")
          .where("employeeId", isEqualTo: selectedEmpId)
          .get();

      if (existingSnapshot.docs.isEmpty) {

        // IF NO RECORD → CREATE NEW
        await FirebaseFirestore.instance
            .collection("gadgets_responsibility")
            .add({
          "employeeId": selectedEmpId,
          "employeeName": selectedEmpName,
          "gadgets": newGadgets,
          "assignedAt": FieldValue.serverTimestamp(),
        });

      } else {

        // RECORD EXISTS → UPDATE IT
        final docId = existingSnapshot.docs.first.id;

        final List<String> currentGadgets =
        List<String>.from(existingSnapshot.docs.first["gadgets"] ?? []);

        // MERGE AND REMOVE DUPLICATES
        final List<String> merged = {
          ...currentGadgets,
          ...newGadgets
        }.toList();

        await FirebaseFirestore.instance
            .collection("gadgets_responsibility")
            .doc(docId)
            .update({
          "employeeName": selectedEmpName,
          "gadgets": merged,
          "assignedAt": FieldValue.serverTimestamp(),
        });
      }

      gadgetsController.clear();

      setState(() {
        selectedEmpId = null;
        selectedEmpName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gadgets Assigned Successfully")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));

    } finally {
      setState(() => isSaving = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors1.darkBackground,

      appBar: AppBar(
        title: const Text(
          "Admin – Gadget Responsibility",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors1.cardBackground,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("gadgets_responsibility")
            .orderBy("assignedAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          final docs = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== HEADER CARD =====
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.all(18),
                //   decoration: BoxDecoration(
                //     color: AppColors1.cardBackground,
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: Colors.white10),
                //   ),
                //
                //   // child: Row(
                //   //   children: const [
                //   //     Icon(Icons.devices,
                //   //         color: AppColors1.primaryAccent,
                //   //         size: 32),
                //   //     SizedBox(width: 14),
                //   //     Expanded(
                //   //       child: Text(
                //   //         "View and assign gadgets responsibility to employees. Existing assignments will be updated automatically.",
                //   //         style: TextStyle(
                //   //             color: Colors.white60,
                //   //             fontSize: 16),
                //   //       ),
                //   //     ),
                //   //   ],
                //   // ),
                // ),

                const SizedBox(height: 22),

                // ===== ASSIGN CARD =====
                Card(
                  color: AppColors1.cardBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                  elevation: 8,
                  margin: const EdgeInsets.only(bottom: 24),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: const [
                            Icon(Icons.person_add_alt_1,
                                color: AppColors1.primaryAccent,
                                size: 26),
                            SizedBox(width: 10),
                            Text(
                              "Assign Gadgets to Employee",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // EMPLOYEE DROPDOWN
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("employee")
                              .where("role", isEqualTo: "employee")
                              .snapshots(),

                          builder: (context, empSnapshot) {

                            if (!empSnapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final employees = empSnapshot.data!.docs;

                            return DropdownButtonFormField<String>(
                              dropdownColor: AppColors1.darkBackground,
                              decoration: _inputDecoration("Select Employee"),

                              value: selectedEmpId,

                              iconEnabledColor: Colors.white70,

                              items: employees.map((doc) {
                                final data =
                                doc.data() as Map<String, dynamic>;

                                return DropdownMenuItem(
                                  value: doc.id,
                                  child: Text(
                                    data["name"] ?? "",
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                );
                              }).toList(),

                              onChanged: (val) {
                                if (val == null) return;

                                final data = employees
                                    .firstWhere((e) => e.id == val)
                                    .data() as Map<String, dynamic>;

                                setState(() {
                                  selectedEmpId = val;
                                  selectedEmpName = data["name"];
                                });
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // GADGET INPUT FIELD
                        TextField(
                          controller: gadgetsController,
                          style: const TextStyle(color: Colors.white70),
                          decoration: _inputDecoration("Enter Gadgets"),
                        ),

                        const SizedBox(height: 24),

                        // ASSIGN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : assignGadgets,
                            icon: const Icon(Icons.save),
                            label: isSaving
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Assign Gadgets"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors1.primaryAccent,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Assigned Gadgets Overview",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // ===== DISPLAY LIST =====
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,

                  itemBuilder: (context, index) {

                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    final List<String> gadgets =
                    List<String>.from(data["gadgets"] ?? []);

                    return Card(
                      color: AppColors1.cardBackground,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),

                      child: ExpansionTile(
                        iconColor: AppColors1.primaryAccent,
                        collapsedIconColor: Colors.white38,

                        title: Row(
                          children: [
                            const Icon(Icons.person,
                                color: Colors.white38),
                            const SizedBox(width: 10),
                            Text(
                              data["employeeName"] ?? "",
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),

                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,

                              children: gadgets.map((g) {
                                return Chip(
                                  avatar: Icon(Icons.devices_other,
                                      color: AppColors1.secondaryAccent,
                                      size: 18),
                                  label: Text(g,
                                      style: const TextStyle(
                                          color: Colors.black)),
                                  backgroundColor:
                                  AppColors1.primaryAccent
                                      .withOpacity(0.1),
                                  padding: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14)),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16, bottom: 14),
                              child: Text(
                                formatDate(data["assignedAt"]),
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
