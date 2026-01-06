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
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _advanceAmountController =
  TextEditingController();

  // 🔴 NEW (ONLY ADDITION)
  final TextEditingController _servicePriceController =
  TextEditingController();
  String? _selectedService;
  double _selectedServicePrice = 0;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  // ---------------- CUSTOMER SEARCH ----------------
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<Map<String, dynamic>> _customerSuggestions = [];

  @override
  void dispose() {
    _removeDropdown();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _placeController.dispose();
    _messageController.dispose();
    _advanceAmountController.dispose();
    _servicePriceController.dispose();
    super.dispose();
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCustomerDropdown() {
    _removeDropdown();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
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
                shrinkWrap: true,
                itemCount: _customerSuggestions.length,
                itemBuilder: (context, index) {
                  final c = _customerSuggestions[index];
                  return ListTile(
                    title: Text(c["name"],
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(c["phone"] ?? "",
                        style: const TextStyle(color: Colors.white70)),
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
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      _removeDropdown();
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("Customer")
        .where("Customer_Name", isGreaterThanOrEqualTo: query)
        .where("Customer_Name", isLessThanOrEqualTo: "$query\uf8ff")
        .limit(5)
        .get();

    _customerSuggestions = snapshot.docs.map((d) {
      final data = d.data();
      return {
        "name": data["Customer_Name"],
        "phone": data["Customer_Mobile_Number"],
      };
    }).toList();

    _customerSuggestions.isEmpty ? _removeDropdown() : _showCustomerDropdown();
  }

  // ---------------- DATE & TIME ----------------
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

  Future<void> _pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    return "${date.day.toString().padLeft(2, '0')} "
        "${months[date.month - 1]} "
        "${date.year}";
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, "0")} ${t.period == DayPeriod.am ? "AM" : "PM"}";

  // ---------------- ASSIGN EMPLOYEE ----------------
  void _showAssignEmployeeSheet(String bookingId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors1.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? empId;
        String? empName;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Assign Employee",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("employee")
                    .where("role", isEqualTo: "employee")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator(
                        color: Colors.white);
                  }

                  final employees = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    dropdownColor: AppColors1.cardBackground,
                    decoration: _inputDecoration("Select Employee"),
                    items: employees.map((e) {
                      final d = e.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(d["name"],
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      empId = v;
                      final emp =
                      employees.firstWhere((e) => e.id == v);
                      empName =
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
                  if (empId == null) return;

                  await FirebaseFirestore.instance
                      .collection("slot_request")
                      .doc(bookingId)
                      .update({
                    "assigned_employee_id": empId,
                    "assigned_employee_name": empName,
                    "status": "approved",
                  });

                  final empDoc = await FirebaseFirestore.instance
                      .collection("employee")
                      .doc(empId)
                      .get();

                  final token = empDoc["fcmToken"];
                  if (token != null) {
                    await PushNotificationService.sendNotification(
                      token: token,
                      title: "New Task Assigned",
                      body:
                      "A new offline order has been assigned to you.",
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

  // ---------------- SAVE ORDER ----------------
  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date & time"),
          backgroundColor: Colors.red,
        ),
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
        "service": _selectedService,
        "service_price": _selectedServicePrice,
        "advance_amount": _advanceAmountController.text.isEmpty
            ? 0
            : double.parse(_advanceAmountController.text),
        "location": _placeController.text.trim(),
        "message": _messageController.text.trim(),
        "date": _formatDate(_selectedDate!),
        "time": _formatTime(_selectedTime!),
        "booking_date": Timestamp.fromDate(
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          ),
        ),

        "status": "pending",
        "source": "offline",
        "created_at": FieldValue.serverTimestamp(),
      });

      _showAssignEmployeeSheet(doc.id);
    } finally {
      setState(() => _isSaving = false);
    }

  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeDropdown,
      child: Scaffold(
        backgroundColor: AppColors1.darkBackground,
        appBar: AppBar(
          title: const Text("Add Offline Order"),
          backgroundColor: AppColors1.cardBackground,
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
                    onChanged: _searchCustomers,
                  ),
                ),
                const SizedBox(height: 12),
                _buildField(_customerPhoneController, "Customer Phone"),
                const SizedBox(height: 12),

                // 🔴 SERVICE DROPDOWN (ONLY CHANGE)
                _serviceDropdown(),
                const SizedBox(height: 12),
                _buildField(_servicePriceController, "Service Price (₹)",
                    readOnly: true),

                const SizedBox(height: 12),
                _buildField(_advanceAmountController,
                    "Advance Payment (₹)",
                    keyboard: TextInputType.number),
                const SizedBox(height: 12),
                _buildField(_placeController, "Place / Location"),

                // 🔴 DATE & TIME (ORIGINAL UI)
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
                          style:
                          const TextStyle(color: Colors.white70),
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
                          style:
                          const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildField(_messageController, "Notes",
                    maxLines: 3),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors1.primaryAccent),
                    child: Text(
                        _isSaving ? "Saving..." : "Save Order"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SERVICE DROPDOWN ----------------
  Widget _serviceDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream:
      FirebaseFirestore.instance.collection("services").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final services = snapshot.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedService,
          dropdownColor: AppColors1.cardBackground,
          decoration: _inputDecoration("Service"),
          items: services.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"]?.toString() ?? "";
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name,
                  style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            final selected = services.firstWhere((d) =>
            (d.data() as Map<String, dynamic>)["name"]
                .toString() ==
                value);

            final data =
            selected.data() as Map<String, dynamic>;

            setState(() {
              _selectedService = value;
              _selectedServicePrice =
                  (data["price"] ?? 0).toDouble();
              _servicePriceController.text =
                  _selectedServicePrice.toString();
            });
          },
        );
      },
    );
  }

  // ---------------- FIELD ----------------
  Widget _buildField(
      TextEditingController c,
      String label, {
        TextInputType keyboard = TextInputType.text,
        String? Function(String?)? validator,
        int maxLines = 1,
        bool readOnly = false,
        void Function(String)? onChanged,
      }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
    );
  }
}
