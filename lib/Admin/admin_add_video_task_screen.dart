import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/services/push_notification_service.dart';

class AdminAddVideoTaskScreen extends StatefulWidget {
  const AdminAddVideoTaskScreen({super.key});

  @override
  State<AdminAddVideoTaskScreen> createState() =>
      _AdminAddVideoTaskScreenState();
}

class _AdminAddVideoTaskScreenState extends State<AdminAddVideoTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String _videoType = "Reel";
  String _priority = "Normal";

  String? _employeeId;
  String? _employeeName;

  DateTime? _deliveryDate;
  bool _saving = false;

  // ------------------ DATE PICKER ------------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  // ------------------ SAVE TASK (FINAL) ------------------
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_employeeId == null || _deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assign employee & select date")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection("video_tasks").add({
        "video_title": _titleController.text.trim(),
        "client_name": _clientController.text.trim(),

        "assigned_employee_id": _employeeId,
        "assigned_employee_name": _employeeName,

        "status": "pending",
        "expected_delivery": Timestamp.fromDate(_deliveryDate!),
        "created_at": FieldValue.serverTimestamp(),
      });

      await PushNotificationService.sendNotificationToAllEmployees(
        title: "🎬 New Video Task",
        body: _titleController.text.trim(),
      );

      Navigator.pop(context);
    } finally {
      setState(() => _saving = false);
    }
  }


  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Add Video Task"),
        backgroundColor: AppColors1.cardBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(_clientController, "Client Name"),
              const SizedBox(height: 12),
              _textField(_titleController, "Video Title"),
              const SizedBox(height: 12),

              _dropdown(
                label: "Video Type",
                value: _videoType,
                items: ["Reel", "Short", "Wedding", "Ad Film", "Other"],
                onChanged: (v) => setState(() => _videoType = v!),
              ),

              const SizedBox(height: 12),

              _dropdown(
                label: "Priority",
                value: _priority,
                items: ["Normal", "Urgent"],
                onChanged: (v) => setState(() => _priority = v!),
              ),

              const SizedBox(height: 12),

              // ---------------- ASSIGN EMPLOYEE ----------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("employee")
                    .where("role", isEqualTo: "employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    dropdownColor: AppColors1.cardBackground,
                    decoration: _decoration("Assign Editor"),
                    value: _employeeId,
                    items: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                          data["name"],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final doc = snapshot.data!.docs
                          .firstWhere((e) => e.id == value);
                      setState(() {
                        _employeeId = value;
                        _employeeName =
                        (doc.data() as Map<String, dynamic>)["name"];
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // ---------------- DELIVERY DATE ----------------
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon:
                const Icon(Icons.calendar_today, color: Colors.white70),
                label: Text(
                  _deliveryDate == null
                      ? "Select Delivery Date"
                      : "${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _saving ? "Saving..." : "Save Task",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ HELPERS ------------------
  Widget _textField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      validator: (v) => v!.trim().isEmpty ? "Required" : null,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors1.cardBackground,
      decoration: _decoration(label),
      style: const TextStyle(color: Colors.white),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors1.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}
