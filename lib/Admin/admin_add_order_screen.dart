import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';
import 'package:urban_advertising/services/push_notification_service.dart';

class AdminAddOrderScreen extends StatefulWidget {
  const AdminAddOrderScreen({super.key});

  @override
  State<AdminAddOrderScreen> createState() => _AdminAddOrderScreenState();
}

class _AdminAddOrderScreenState extends State<AdminAddOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
  TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;
  @override
  void dispose() {
    _removeDropdown();   // ← IMPORTANT
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _serviceController.dispose();
    _placeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --------------------- DROPDOWN SUPPORT ---------------------
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<Map<String, dynamic>> _customerSuggestions = [];

  void _removeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _showCustomerDropdown() {
    _removeDropdown();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 150,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 55),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors1.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _customerSuggestions.length,
                  itemBuilder: (context, index) {
                    final c = _customerSuggestions[index];

                    return ListTile(
                      dense: true,
                      title: Text(c["name"],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        c["phone"] ?? "",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      onTap: () {
                        _customerNameController.text = c["name"];
                        _customerPhoneController.text = c["phone"];
                        _removeDropdown();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // --------------------- UPDATED SEARCH FUNCTION ---------------------
  Future<void> _searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      _removeDropdown();
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("Customer") // FIXED COLLECTION NAME
        .where("Customer_Name", isGreaterThanOrEqualTo: query)
        .where("Customer_Name", isLessThanOrEqualTo: "$query\uf8ff")
        .limit(5)
        .get();

    _customerSuggestions = snapshot.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {
        "id": d.id,
        "name": data["Customer_Name"] ?? "",
        "phone": data["Customer_Mobile_Number"] ?? "",
        "email": data["Customer_Email"] ?? "",
      };
    }).toList();

    if (_customerSuggestions.isEmpty) {
      _removeDropdown();
    } else {
      _showCustomerDropdown();
    }
  }

  // --------------------- DATE PICKER ---------------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --------------------- TIME PICKER ---------------------
  Future<void> _pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // Formatters
  String _formatDate(DateTime date) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTime(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, "0");
    final period = tod.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // ------------------ ASSIGN EMPLOYEE SHEET ------------------
  void _showAssignEmployeeSheet(String bookingId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors1.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? selectedEmpId;
        String? selectedEmpName;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Assign Employee",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("employee")
                    .where("role", isEqualTo: "employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  final employees = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    dropdownColor: AppColors1.cardBackground,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      labelText: "Select Employee",
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: employees.map((e) {
                      final emp = e.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(emp["name"],
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedEmpId = value;
                      final emp = employees.firstWhere((el) => el.id == value);
                      selectedEmpName =
                      (emp.data() as Map<String, dynamic>)["name"];
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent),
                onPressed: () async {
                  if (selectedEmpId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select employee"),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection("slot_request")
                      .doc(bookingId)
                      .update({
                    "assigned_employee_id": selectedEmpId,
                    "assigned_employee_name": selectedEmpName,
                    "status": "approved",
                  });

                  final empDoc = await FirebaseFirestore.instance
                      .collection("employee")
                      .doc(selectedEmpId)
                      .get();

                  final token = empDoc["fcmToken"];
                  if (token != null) {
                    await PushNotificationService.sendNotification(
                      token: token,
                      title: "New Task Assigned",
                      body: "A new offline order has been assigned to you.",
                    );
                  }

                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Assign Task",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  // ------------------- SAVE ORDER -------------------
  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date & time")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection("slot_request")
          .add({
        "customer_name": _customerNameController.text.trim(),
        "customer_phone": _customerPhoneController.text.trim(),
        "service": _serviceController.text.trim(),
        "location": _placeController.text.trim(),
        "message": _messageController.text.trim(),
        "date": _formatDate(_selectedDate!),
        "time": _formatTime(_selectedTime!),
        "status": "pending",
        "source": "offline",
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Offline order created. Assign employee."),
            backgroundColor: Colors.green),
      );

      _showAssignEmployeeSheet(doc.id);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ------------------ FIELD UI ------------------
  Widget _buildField(
      TextEditingController c,
      String label, {
        TextInputType keyboard = TextInputType.text,
        String? Function(String?)? validator,
        int maxLines = 1,
        void Function(String)? onChanged,
      }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors1.cardBackground,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ------------------ UI BUILD ------------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeDropdown,
      child: Scaffold(
        backgroundColor: AppColors1.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors1.cardBackground,
          title: const Text("Add Offline Order",
              style: TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: _buildField(
                    _customerNameController,
                    "Customer Name",
                    validator: (v) =>
                    v!.trim().isEmpty ? "Required" : null,
                    onChanged: (value) => _searchCustomers(value),
                  ),
                ),

                const SizedBox(height: 12),
                _buildField(_customerPhoneController, "Customer Phone",
                    keyboard: TextInputType.phone),

                const SizedBox(height: 12),
                _buildField(_serviceController, "Service"),

                const SizedBox(height: 12),
                _buildField(_placeController, "Place / Location"),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.white70),
                        label: Text(
                          _selectedDate == null
                              ? "Select Date"
                              : _formatDate(_selectedDate!),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time,
                            color: Colors.white70),
                        label: Text(
                          _selectedTime == null
                              ? "Select Time"
                              : _formatTime(_selectedTime!),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildField(_messageController, "Notes (optional)",
                    maxLines: 3),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors1.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isSaving ? "Saving..." : "Save Order",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
